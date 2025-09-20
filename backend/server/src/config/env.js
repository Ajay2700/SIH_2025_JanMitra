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
  SUPABASE_ANON_KEY: getEnv('SUPABASE_ANON_KEY'),
  SUPABASE_SERVICE_ROLE_KEY: getEnv('SUPABASE_SERVICE_ROLE_KEY'),
  DEFAULT_USERS: {
    citizen: {
      email: getEnv('CITIZEN_EMAIL'),
      password: getEnv('CITIZEN_PASSWORD'),
      name: getEnv('CITIZEN_FULL_NAME', 'Citizen'),
      phone: getEnv('CITIZEN_PHONE', ''),
      address: getEnv('CITIZEN_ADDRESS', ''),
      user_type: 'citizen',
    },
    staff: {
      email: getEnv('STAFF_EMAIL'),
      password: getEnv('STAFF_PASSWORD'),
      name: getEnv('STAFF_FULL_NAME', 'Staff'),
      phone: getEnv('STAFF_PHONE', ''),
      address: getEnv('STAFF_ADDRESS', ''),
      user_type: 'staff',
    },
    admin: {
      email: getEnv('ADMIN_EMAIL'),
      password: getEnv('ADMIN_PASSWORD'),
      name: getEnv('ADMIN_FULL_NAME', 'Admin'),
      phone: getEnv('ADMIN_PHONE', ''),
      address: getEnv('ADMIN_ADDRESS', ''),
      user_type: 'admin',
    },
  },
};


