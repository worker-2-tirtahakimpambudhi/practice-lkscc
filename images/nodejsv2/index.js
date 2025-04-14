import express from "express";
import multer from "multer";
import { v4 as uuidv4 } from "uuid";
import {
    S3Client,
    PutObjectCommand
} from "@aws-sdk/client-s3";

// Store files in memory instead of disk for easier S3 uploading
const multerClient = multer({ storage: multer.memoryStorage() });

// Configure AWS S3 Client
const s3Client = new S3Client({
    region: process.env.REGION || "us-east-1",
    credentials: {
        accessKeyId: process.env.ACCESS_KEY,
        secretAccessKey: process.env.SECRET_KEY,
        ...(process.env.SESSION_TOKEN ? { sessionToken: process.env.SESSION_TOKEN } : {})
    },
    ...(process.env.ENDPOINT ? { endpoint: process.env.ENDPOINT, forcePathStyle: true } : {})
});

const app = express();

app.get("/", (req, res) => {
    res.sendStatus(200);
});

app.post("/upload", multerClient.single("image"), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: "No file uploaded" });
        }

        const fileKey = `${uuidv4()}-${req.file.originalname}`;

        const uploadParams = {
            Bucket: process.env.BUCKET_NAME,
            Key: fileKey,
            Body: req.file.buffer,
            ContentType: req.file.mimetype
        };

        await s3Client.send(new PutObjectCommand(uploadParams));

        res.status(200).json({
            message: "File uploaded successfully",
            fileKey,
            fileUrl: process.env.ENDPOINT
                ? `${process.env.ENDPOINT}/${fileKey}`
                : `https://${process.env.BUCKET_NAME}.s3.amazonaws.com/${fileKey}`
        });
    } catch (error) {
        console.error("Error uploading to S3:", error);
        res.status(500).json({ error: "Failed to upload file" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, process.env.HOST || "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
});
