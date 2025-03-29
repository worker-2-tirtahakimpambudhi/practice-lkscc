package main

import (
	"context"
	"crypto/tls"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var (
	db    *sql.DB
	rdb   *redis.Client
	ctx   = context.Background()
	port  = "8080"
	host  = "0.0.0.0"
)

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

	options := &redis.Options{
		Addr: os.Getenv("REDIS_HOST")+":"+os.Getenv("REDIS_PORT"),
		DB: 1,
	}

	if os.Getenv("REDIS_TLS") == "true" {
		options.TLSConfig = &tls.Config{
			InsecureSkipVerify: true, // Set to false in production for better security
		}
	}

	if os.Getenv("REDIS_USER") != "" {
		options.Username = os.Getenv("REDIS_USERNAME")
	}

	if os.Getenv("REDIS_PASSWORD") != "" {
		options.Password = os.Getenv("REDIS_PASSWORD")
	}

	// Initialize Redis connection
	rdb = redis.NewClient(options)
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
	addr := host+":"+port
	r := gin.Default()
	r.GET("/health", healthCheck)
	
	log.Printf("Starting server on %s \n", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}