import { Response, NextFunction } from 'express';
import { AuthRequest } from '../types';
import { verifyToken } from '../utils/auth';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      res.status(401).json({ 
        success: false, 
        message: 'Access denied. No token provided.' 
      });
      return;
    }

    const decoded = verifyToken(token);
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
    });

    if (!user) {
      res.status(401).json({ 
        success: false, 
        message: 'Invalid token.' 
      });
      return;
    }

    if (!user.isActive) {
      res.status(401).json({ 
        success: false, 
        message: 'Account is deactivated.' 
      });
      return;
    }

    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ 
      success: false, 
      message: 'Invalid token.' 
    });
  }
};

// Middleware untuk authorize multiple roles
export const authorize = (allowedRoles: string | string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];
    
    // SUPER_ADMIN memiliki akses ke semua endpoint
    const superAdminRoles = [
      'SUPER_ADMIN', // legacy
      'SUPER_ADMIN_FINANCE', 
      'SUPER_ADMIN_APO', 
      'SUPER_ADMIN_FRONT_DESK', 
      'SUPER_ADMIN_ONSITE'
    ];

    // Jika user adalah super admin, izinkan akses
    if (superAdminRoles.includes(req.user.role)) {
      return next();
    }

    // Untuk user biasa, cek role
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient permissions'
      });
    }

    next();
  };
};