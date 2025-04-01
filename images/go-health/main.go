package main

import (
	"context"
	"crypto/tls"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	goredis "github.com/redis/go-redis/v9"
	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var (
	db    *sql.DB
	rdb   goredis.UniversalClient
	ctx   = context.Background()
	port  = "8080"
	host  = "0.0.0.0"
)

func initRedisClient() goredis.UniversalClient {
	// Determine if it's a cluster or single instance
	isCluster := os.Getenv("REDIS_CLUSTER") == "true"

	// Parse Redis hosts
	redisHosts := strings.Split(os.Getenv("REDIS_HOSTS"), ",")

	// TLS Configuration
	tlsConfig := &tls.Config{
		InsecureSkipVerify: os.Getenv("REDIS_TLS_INSECURE") == "true",
	}

	// Check if TLS is enabled
	useTLS := os.Getenv("REDIS_TLS") == "true"

	if isCluster {
		// Redis Cluster Configuration
		clusterOptions := &goredis.ClusterOptions{
			Addrs:    redisHosts,

			// Connection Pool Configuration
			PoolSize:     10,
			MinIdleConns: 10,

			// Timeout Configurations
			DialTimeout:  5 * time.Second,
			ReadTimeout:  3 * time.Second,
			WriteTimeout: 3 * time.Second,
			PoolTimeout:  4 * time.Second,

			// Retry Mechanism
			MaxRetries:      10,
			MinRetryBackoff: 8 * time.Millisecond,
			MaxRetryBackoff: 512 * time.Millisecond,

			// Routing and Read Configurations
			ReadOnly:       false,
			RouteRandomly:  false,
			RouteByLatency: false,
		}

		// Add TLS Config if enabled
		if useTLS {
			clusterOptions.TLSConfig = tlsConfig
		}

		if os.Getenv("REDIS_USERNAME") != "" {
			clusterOptions.Username = os.Getenv("REDIS_USERNAME")
		}

		if os.Getenv("REDIS_PASSWORD") != "" {
			clusterOptions.Password = os.Getenv("REDIS_PASSWORD")
		}

		log.Println("Initializing Redis Cluster Client")
		return goredis.NewClusterClient(clusterOptions)
	} else {
		// Single Redis Instance Configuration
		redisOptions := &goredis.Options{
			Addr:     redisHosts[0], // Use first host for single instance
			DB:       0, // Default database

			// Connection Pool Configuration
			PoolSize:     10,
			MinIdleConns: 10,

			// Timeout Configurations
			DialTimeout:  5 * time.Second,
			ReadTimeout:  3 * time.Second,
			WriteTimeout: 3 * time.Second,
			PoolTimeout:  4 * time.Second,
		}

		// Add TLS Config if enabled
		if useTLS {
			redisOptions.TLSConfig = tlsConfig
		}
		if os.Getenv("REDIS_USERNAME") != "" {
			redisOptions.Username = os.Getenv("REDIS_USERNAME")
		}

		if os.Getenv("REDIS_PASSWORD") != "" {
			redisOptions.Password = os.Getenv("REDIS_PASSWORD")
		}

		log.Println("Initializing Single Redis Client")
		return goredis.NewClient(redisOptions)
	}
}

func init() {
	err := godotenv.Load()
	if err != nil {
		log.Printf("No .env file found, using environment variables")
	}

	// Initialize MySQL connection
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		os.Getenv("MYSQL_USER"),
		os.Getenv("MYSQL_PASSWORD"),
		os.Getenv("MYSQL_HOST"),
		os.Getenv("MYSQL_PORT"),
		os.Getenv("MYSQL_DATABASE"),
	)

	db, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("Error connecting to MySQL: %v", err)
	}

	if os.Getenv("PORT") != "" {
		port = os.Getenv("PORT")
	}

	if os.Getenv("HOST") != "" {
		host = os.Getenv("HOST")
	}

	// Initialize Redis Client
	rdb = initRedisClient()

	// Verify initial connection
	_, err = rdb.Ping(ctx).Result()
	if err != nil {
		log.Fatalf("Failed to connect to Redis: %v", err)
	}
}

func healthCheck(c *gin.Context) {
	// Check MySQL connection
	if err := db.Ping(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "MySQL connection failed", "error": err.Error()})        
		return
	}

	// Check Redis connection
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "Redis connection failed", "error": err.Error()})        
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "OK"})
}

func main() {
	defer db.Close()
	defer func() {
		// Proper close based on client type
		switch client := rdb.(type) {
		case *goredis.ClusterClient:
			client.Close()
		case *goredis.Client:
			client.Close()
		}
	}()

	addr := host+":"+port
	r := gin.Default()
	r.GET("/health", healthCheck)

	log.Printf("Starting server on %s \n", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}