import express from "express";
import multer from "multer";
import { v4 as uuidv4 } from "uuid";
import AWS from "aws-sdk";

try {
    // Store files in memory instead of disk for easier S3 uploading
    const multerClient = multer({ storage: multer.memoryStorage() });

    // Configure AWS SDK
    const s3 = new AWS.S3({
        region: process.env.REGION || 'us-east-1',
        accessKeyId: process.env.ACCESS_KEY,
        secretAccessKey: process.env.SECRET_KEY,
        ...(process.env.SESSION_TOKEN ? { sessionToken: process.env.SESSION_TOKEN } : {}),
        ...(process.env.ENDPOINT ? { endpoint: process.env.ENDPOINT } : {}),
        ...(process.env.ENDPOINT ? { s3ForcePathStyle: true } : {})
    });

    const app = express();
    app.get('/', (req,res) => {
        res.sendStatus(200);
    });
    app.post('/upload', multerClient.single('image'), async (req, res) => {
        try {
            if (!req.file) {
                return res.status(400).json({ error: 'No file uploaded' });
            }

            // Generate a unique filename using UUID
            const fileKey = `${uuidv4()}-${req.file.originalname}`;
            // Set up S3 upload parameters
            const params = {
                Bucket: process.env.BUCKET_NAME,
                Key: fileKey,
                Body: req.file.buffer,
                ContentType: req.file.mimetype
            };

            // Upload to S3
            s3.upload(params, (err, data) => {
                if (err) {
                    console.error('Error uploading to S3:', err);
                    return res.status(500).json({ error: 'Failed to upload file' });
                }

                // Send success response with the file location
                res.status(200).json({
                    message: 'File uploaded successfully',
                    fileKey: fileKey,
                    fileUrl: process.env.ENDPOINT
                        ? `${process.env.ENDPOINT}/${fileKey}`
                        : `https://${process.env.BUCKET_NAME}.s3.amazonaws.com/${fileKey}`,
                    data: data // Include the response from S3
                });
            });
        } catch (error) {
            console.error('Error in upload handler:', error);
            res.status(500).json({ error: 'Failed to process upload' });
        }
    });

    // Add server initialization
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, process.env.HOST || '0.0.0.0', () => {
        console.log(`Server running on port ${PORT}`);
    });

} catch (error) {
    console.error(error);
    process.exit(1);
}