import { Response } from 'express';
import { AuthRequest, AttendanceFormDataRequest } from '../types';
import { AttendanceService } from '../services/attendance-service';
import { Division, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const attendanceService = new AttendanceService();

export class AttendanceController {
  async checkIn(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Handle form-data request
      const { lat, lng } = req.body as AttendanceFormDataRequest;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          message: 'Latitude dan longitude diperlukan',
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'Foto selfie diperlukan',
        });
        return;
      }

      const location = `${lat},${lng}`;
      const date = new Date();

      const attendance = await attendanceService.checkIn(req.user.id, {
        date,
        location,
        selfie: req.file.buffer, // Kirim buffer file langsung
        note: req.body.note || '',
      });

      res.json({
        success: true,
        message: 'Check-in berhasil',
        data: attendance,
      });
    } catch (error: any) {
      console.error('Check-in error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Check-in gagal',
      });
    }
  }

  async checkOut(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Handle form-data request
      const { lat, lng } = req.body as AttendanceFormDataRequest;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          message: 'Latitude dan longitude diperlukan',
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'Foto selfie diperlukan',
        });
        return;
      }

      const location = `${lat},${lng}`;
      const date = new Date();

      const attendance = await attendanceService.checkOut(req.user.id, {
        date,
        location,
        selfie: req.file.buffer, // Kirim buffer file langsung
      });

      res.json({
        success: true,
        message: 'Check-out berhasil',
        data: attendance,
      });
    } catch (error: any) {
      console.error('Check-out error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Check-out gagal',
      });
    }
  }

  async getAttendanceHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { startDate, endDate } = req.query;
      const start = startDate ? new Date(startDate as string) : new Date();
      const end = endDate ? new Date(endDate as string) : new Date();

      start.setDate(start.getDate() - 30); // Default to last 30 days

      const attendances = await attendanceService.getAttendanceHistory(
        req.user.id,
        start,
        end
      );
      console.log(attendances)
      res.json({
        success: true,
        data: attendances,
      });
    } catch (error: any) {
      console.error('Get attendance history error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get attendance history',
      });
    }
  }

  async getAttendanceSummary(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { month, year } = req.query;
      const currentDate = new Date();
      const targetMonth = month ? parseInt(month as string) : currentDate.getMonth() + 1;
      const targetYear = year ? parseInt(year as string) : currentDate.getFullYear();

      const summary = await attendanceService.getAttendanceSummary(
        req.user.id,
        targetMonth,
        targetYear
      );

      res.json({
        success: true,
        data: summary,
      });
    } catch (error: any) {
      console.error('Get attendance summary error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get attendance summary',
      });
    }
  }

  async manualAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { userId, date, checkIn, checkOut, reason } = req.body;

      const user = await prisma.user.findFirst({
        where: {
          id: req.user.id
        },
        select: {
          division: true
        }
      })
      if (!req.user || req.user.division === user?.division ) {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const attendance = await prisma.attendance.create({
        data: {
          userId: parseInt(userId),
          date: new Date(date),
          checkIn: checkIn ? new Date(checkIn) : null,
          checkOut: checkOut ? new Date(checkOut) : null,
          status: 'PRESENT',
          notes: `Manual entry: ${reason}`,
        },
      });

      res.json({
        success: true,
        message: 'Manual attendance recorded successfully',
        data: attendance,
      });
    } catch (error: any) {
      console.error('Manual attendance error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to record manual attendance',
      });
    }
  }

  async getTodayAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const attendance = await prisma.attendance.findFirst({
        where: {
          userId: req.user.id,
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      });

      res.json({
        success: true,
        data: attendance,
      });
    } catch (error: any) {
      console.error('Get today attendance error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get today attendance',
      });
    }
  }

  async getAttendanceHistoryByDivision(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
      }

      const { startDate, endDate } = req.query;

      let start: Date;
      let end: Date;

      if (startDate && endDate) {
        start = new Date(startDate as string);
        end = new Date(endDate as string);
      } else {
        // Default: 30 hari ke belakang
        end = new Date();
        start = new Date();
        start.setDate(start.getDate() - 30);
      }

      const attendances = await attendanceService.getAttendanceHistoryByDivision(
        req.user!.division,
        start,
        end
      );

      res.json({
        success: true,
        data: attendances,
      });
    } catch (error: any) {
      console.error("Get attendance history error:", error);
      res.status(400).json({
        success: false,
        message: error.message || "Failed to get attendance history",
      });
    }
  }
}