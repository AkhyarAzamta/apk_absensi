// seeders/division-settings.ts
import { PrismaClient, Division } from '@prisma/client';

export async function seedDivisionSettings(prisma: PrismaClient) {
  console.log('🏢 Seeding division settings...');

  const divisionSettings = [
    {
      division: Division.FINANCE,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 1000,
      baseSalary: 8000000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.APO,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 900,
      baseSalary: 7500000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.FRONT_DESK,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 800,
      baseSalary: 6000000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.ONSITE,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 850,
      baseSalary: 7000000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
  ];

  for (const setting of divisionSettings) {
    await prisma.divisionSetting.upsert({
      where: { division: setting.division },
      update: setting,
      create: setting,
    });
    console.log(`✅ Division setting created for: ${setting.division}`);
  }

  console.log('✅ Division settings seeded');
}