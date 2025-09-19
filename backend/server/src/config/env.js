import dotenv from 'dotenv';
dotenv.config();

function getEnv(name, fallback) {
  const value = process.env[name] ?? fallback;
  if (value === undefined) {
    throw new Error(`Missing env var: ${name}`);
  }
  return value;
}

export const env = {
  PORT: Number(getEnv('PORT', '4000')),
  NODE_ENV: getEnv('NODE_ENV', 'development'),
  SUPABASE_URL: getEnv('SUPABASE_URL'),
  SUPABASE_SERVICE_ROLE_KEY: getEnv('SUPABASE_SERVICE_ROLE_KEY'),
  JWT_SECRET: getEnv('JWT_SECRET'),
  JWT_EXPIRES_IN: getEnv('JWT_EXPIRES_IN', '7d'),
  DEFAULT_USERS: {
    citizen: {
      email: getEnv('CITIZEN_EMAIL'),
      password: getEnv('CITIZEN_PASSWORD'),
      full_name: getEnv('CITIZEN_FULL_NAME', 'Citizen'),
      phone_number: getEnv('CITIZEN_PHONE', ''),
      address: getEnv('CITIZEN_ADDRESS', ''),
      role: 'citizen',
    },
    staff: {
      email: getEnv('STAFF_EMAIL'),
      password: getEnv('STAFF_PASSWORD'),
      full_name: getEnv('STAFF_FULL_NAME', 'Staff'),
      phone_number: getEnv('STAFF_PHONE', ''),
      address: getEnv('STAFF_ADDRESS', ''),
      role: 'staff',
    },
    admin: {
      email: getEnv('ADMIN_EMAIL'),
      password: getEnv('ADMIN_PASSWORD'),
      full_name: getEnv('ADMIN_FULL_NAME', 'Admin'),
      phone_number: getEnv('ADMIN_PHONE', ''),
      address: getEnv('ADMIN_ADDRESS', ''),
      role: 'admin',
    },
  },
};


