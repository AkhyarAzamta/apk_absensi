import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class OnsiteController {
    getOnsiteLocations(req: AuthRequest, res: Response): Promise<void>;
    getOnsiteLocationById(req: AuthRequest, res: Response): Promise<void>;
    createOnsiteLocation(req: AuthRequest, res: Response): Promise<void>;
    updateOnsiteLocation(req: AuthRequest, res: Response): Promise<void>;
    deleteOnsiteLocation(req: AuthRequest, res: Response): Promise<void>;
    toggleLocationStatus(req: AuthRequest, res: Response): Promise<void>;
    validateGPSCheckIn(req: AuthRequest, res: Response): Promise<void>;
    getFieldMonitoring(_req: AuthRequest, res: Response): Promise<void>;
    processOvertimeOnsite(req: AuthRequest, res: Response): Promise<void>;
    getOnsiteAttendanceReport(req: AuthRequest, res: Response): Promise<void>;
    private groupEmployeesByLocation;
    private getLocationName;
}
export declare const onsiteController: OnsiteController;
//# sourceMappingURL=onsite-controller.d.ts.map