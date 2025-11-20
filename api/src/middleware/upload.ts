// api/src/middleware/upload.ts
import multer from 'multer';
import { Request, Response, NextFunction } from 'express';

// Configure storage
const storage = multer.memoryStorage();

// File filter for images only
const fileFilter = (_req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  console.log('Uploading file:', file.originalname, file.mimetype);
  
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar yang diizinkan!'));
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
});

// Middleware untuk menangani error upload
export const handleUploadError = (error: any, _req: Request, res: Response, next: NextFunction): void => {
  console.log('Upload error:', error);
  
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      res.status(400).json({
        success: false,
        message: 'File terlalu besar. Maksimal 5MB',
      });
      return;
    }
    if (error.code === 'LIMIT_UNEXPECTED_FILE') {
      res.status(400).json({
        success: false,
        message: 'Field file tidak sesuai',
      });
      return;
    }
  } else if (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next();
};

export const uploadSinglePhoto = upload.single('photo');