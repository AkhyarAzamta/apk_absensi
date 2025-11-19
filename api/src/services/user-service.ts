import { PrismaClient, User, Division } from '@prisma/client';
import { hashPassword } from '../utils/auth';

const prisma = new PrismaClient();

// Define type without password
type UserWithoutPassword = Omit<User, 'password'>;

// Helper function untuk parse date
const parseDate = (dateInput: string | Date): Date => {
  if (dateInput instanceof Date) {
    return dateInput;
  }
  
  // Coba parse sebagai ISO string
  let date = new Date(dateInput);
  if (!isNaN(date.getTime())) {
    return date;
  }
  
  // Jika gagal, coba format YYYY-MM-DD
  const match = dateInput.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (match) {
    const [_, year, month, day] = match;
    date = new Date(Date.UTC(parseInt(year), parseInt(month) - 1, parseInt(day)));
    if (!isNaN(date.getTime())) {
      return date;
    }
  }
  
  throw new Error(`Invalid date format: ${dateInput}`);
};

export class UserService {
  async getAllUsers(division?: Division): Promise<UserWithoutPassword[]> {
    const whereClause = division ? { division, isActive: true } : { isActive: true };
    
    return await prisma.user.findMany({
      where: whereClause,
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword[];
  }

  async getUserById(id: number): Promise<UserWithoutPassword | null> {
    return await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword | null;
  }

  async createUser(userData: {
    employeeId: string;
    name: string;
    email: string;
    password: string;
    division: Division;
    position: string;
    joinDate: string | Date;
    phone?: string;
    address?: string;
    photo?: string;
  }): Promise<UserWithoutPassword> {
    const hashedPassword = await hashPassword(userData.password);

    // Parse joinDate dengan fungsi helper
    const joinDate = parseDate(userData.joinDate);

    return await prisma.user.create({
      data: {
        ...userData,
        joinDate: joinDate,
        password: hashedPassword,
      },
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword;
  }
  async updateUser(
    id: number, 
    updateData: Partial<Omit<User, 'id' | 'password'>>
  ): Promise<UserWithoutPassword> {
    return await prisma.user.update({
      where: { id },
      data: updateData,
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword;
  }

  async deleteUser(id: number): Promise<UserWithoutPassword> {
    return await prisma.user.update({
      where: { id },
      data: { isActive: false },
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword;
  }

  async getUsersByDivision(division: Division): Promise<UserWithoutPassword[]> {
    return await prisma.user.findMany({
      where: { division, isActive: true },
      select: {
        id: true,
        employeeId: true,
        name: true,
        email: true,
        division: true,
        role: true,
        position: true,
        joinDate: true,
        phone: true,
        address: true,
        photo: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as UserWithoutPassword[];
  }
}