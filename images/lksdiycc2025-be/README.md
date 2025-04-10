## LKS Cloud Computing DIY 2025

Repository ini merupakan aplikasi backend dengan bahasa golang yang digunakan untuk seleksi LKS DIY 2025 bidang Cloud Computing.
```
        ∩∩   ♡      i will always be  
     (・⩊・ )         moo-ing for you  
   ∩ ∩(   っ⌒っ       with love & hugs  
 ⊂⌒(　　・ω・)ノ        for lkscc fighter!
　 ＼_つ＿/￣￣￣/  
　　　 ＼/＿＿＿/
```

### Prerequisites
- Docker
- Docker Compose
- AWS S3 Credentials

### Init repo
Just run those simple command!
```sh
go mod init
   ```
then
```sh
go mod tidy
   ```

### Environment Variables
Create a `.env` file and configure the following environment variables:
```env
DB_USER=yourdbuser
DB_PASS=somethingsecret
DB_HOST=db
DB_PORT=3306
DB_NAME=student_db

REDIS_ADDR=redis:6379

AWS_REGION=us-east-1
AWS_ACCESS_KEY=your_access_key
AWS_SECRET_KEY=your_secret_key
AWS_BUCKET_NAME=your_bucket_name
```

### How to Run with Docker
1. Build and run the container:
   ```sh
   docker-compose up --build -d
   ```
2. The API will be available at `http://YOUR_IP_ADDRESS:8080`

### API Endpoints
| Method | Endpoint               | Description              |
|--------|------------------------|--------------------------|
| POST   | `/students`            | Create a student        |
| GET    | `/students`            | Get all students        |
| GET    | `/students/:id`        | Get student by ID       |
| PUT    | `/students/:id`        | Update student          |
| DELETE | `/students/:id`        | Delete student          |
| GET    | `/students/cache/:id`  | Get student from cache  |

3. Stop the container:
   ```sh
   docker-compose down
   ```
---
