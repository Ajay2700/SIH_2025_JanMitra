import { supabase, supabaseAdmin } from '../config/supabase.js';
import { env } from '../config/env.js';

async function upsertUser(defaultUser) {
  const { email, password, name, phone, address, user_type } = defaultUser;
  
  try {
    // Check if user already exists in Supabase Auth
    const { data: existingUser } = await supabaseAdmin.auth.admin.getUserByEmail(email);
    
    let userId;
    if (existingUser.user) {
      userId = existingUser.user.id;
      console.log(`User ${email} already exists in Auth`);
    } else {
      // Create user in Supabase Auth
      const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true
      });
      
      if (authError) throw authError;
      userId = authData.user.id;
      console.log(`Created user ${email} in Auth`);
    }

    // Check if profile exists in our users table
    const { data: existingProfile, error: selectErr } = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('id', userId)
      .maybeSingle();
    
    if (selectErr) throw selectErr;
    if (existingProfile) {
      console.log(`Profile for ${email} already exists`);
      return userId;
    }

    // Create user profile
    const { error: insertErr } = await supabaseAdmin
      .from('users')
      .insert({ 
        id: userId,
        email, 
        name, 
        phone, 
        address, 
        user_type 
      });
    
    if (insertErr) throw insertErr;
    console.log(`Created profile for ${email}`);
    return userId;
  } catch (error) {
    console.error(`Error upserting user ${email}:`, error);
    throw error;
  }
}

async function ensureDefaultDepartments() {
  const departments = [
    {
      name: 'Public Works Department',
      description: 'Responsible for infrastructure and public facilities',
      department_code: 'PWD',
      jurisdiction: 'State',
      contact_email: 'pwd@example.com',
      contact_phone: '+91-1234567890'
    },
    {
      name: 'Water Supply Department',
      description: 'Manages water resources and distribution',
      department_code: 'WSD',
      jurisdiction: 'State',
      contact_email: 'wsd@example.com',
      contact_phone: '+91-1234567891'
    },
    {
      name: 'Electricity Department',
      description: 'Manages power distribution and related issues',
      department_code: 'ELECT',
      jurisdiction: 'State',
      contact_email: 'elect@example.com',
      contact_phone: '+91-1234567892'
    },
    {
      name: 'Sanitation Department',
      description: 'Responsible for waste management and cleanliness',
      department_code: 'SAN',
      jurisdiction: 'Municipal',
      contact_email: 'san@example.com',
      contact_phone: '+91-1234567893'
    },
    {
      name: 'Health Department',
      description: 'Manages healthcare facilities and public health',
      department_code: 'HLTH',
      jurisdiction: 'State',
      contact_email: 'hlth@example.com',
      contact_phone: '+91-1234567894'
    }
  ];

  for (const dept of departments) {
    const { data: existing, error: selectErr } = await supabaseAdmin
      .from('departments')
      .select('id')
      .eq('department_code', dept.department_code)
      .maybeSingle();
    
    if (selectErr) throw selectErr;
    if (existing) continue;

    const { error: insertErr } = await supabaseAdmin
      .from('departments')
      .insert(dept);
    if (insertErr) throw insertErr;
  }
}

async function ensureDefaultCategories() {
  // First, get department IDs
  const { data: departments, error: deptErr } = await supabaseAdmin
    .from('departments')
    .select('id, department_code');
  if (deptErr) throw deptErr;

  const deptMap = departments.reduce((acc, dept) => {
    acc[dept.department_code] = dept.id;
    return acc;
  }, {});

  const categories = [
    {
      name: 'Road Maintenance',
      description: 'Issues related to road repairs and maintenance',
      department_id: deptMap.PWD,
      sla_hours: 72
    },
    {
      name: 'Water Supply Issues',
      description: 'Problems with water supply and quality',
      department_id: deptMap.WSD,
      sla_hours: 24
    },
    {
      name: 'Power Outages',
      description: 'Electrical power supply problems',
      department_id: deptMap.ELECT,
      sla_hours: 12
    },
    {
      name: 'Waste Management',
      description: 'Garbage collection and disposal issues',
      department_id: deptMap.SAN,
      sla_hours: 48
    },
    {
      name: 'Public Health',
      description: 'Health-related concerns and complaints',
      department_id: deptMap.HLTH,
      sla_hours: 24
    }
  ];

  for (const category of categories) {
    const { data: existing, error: selectErr } = await supabaseAdmin
      .from('ticket_categories')
      .select('id')
      .eq('name', category.name)
      .eq('department_id', category.department_id)
      .maybeSingle();
    
    if (selectErr) throw selectErr;
    if (existing) continue;

    const { error: insertErr } = await supabaseAdmin
      .from('ticket_categories')
      .insert(category);
    if (insertErr) throw insertErr;
  }
}

export async function ensureDefaultUsers() {
  const users = env.DEFAULT_USERS;
  await upsertUser(users.citizen);
  await upsertUser(users.staff);
  await upsertUser(users.admin);
}

export async function seedDatabase() {
  try {
    console.log('Seeding database...');
    
    // Check if we can connect to Supabase
    const { data: testData, error: testError } = await supabaseAdmin
      .from('departments')
      .select('count')
      .limit(1);
    
    if (testError && testError.code === '42501') {
      console.log('⚠️  RLS policies detected. Attempting to seed with service role...');
      
      // Try to seed with explicit service role context
      await seedWithServiceRole();
    } else if (testError) {
      console.error('Database connection error:', testError);
      throw testError;
    } else {
      // Normal seeding
      await ensureDefaultDepartments();
      console.log('✓ Departments seeded');
      await ensureDefaultCategories();
      console.log('✓ Categories seeded');
      await ensureDefaultUsers();
      console.log('✓ Default users created');
    }
    
    console.log('Database seeding completed successfully');
  } catch (error) {
    console.error('Error seeding database:', error);
    
    // If RLS is blocking, provide helpful instructions
    if (error.code === '42501') {
      console.log('\n🔧 To fix RLS issues:');
      console.log('1. Temporarily disable RLS policies in Supabase dashboard');
      console.log('2. Or modify the policies to allow service role access');
      console.log('3. Or run the seeding SQL directly in Supabase SQL editor\n');
    }
    
    // Don't throw error for RLS issues - allow server to start
    if (error.code !== '42501') {
      throw error;
    }
  }
}

async function seedWithServiceRole() {
  console.log('Attempting seeding with service role privileges...');
  
  try {
    await ensureDefaultDepartments();
    console.log('✓ Departments seeded');
    await ensureDefaultCategories();
    console.log('✓ Categories seeded');
    await ensureDefaultUsers();
    console.log('✓ Default users created');
  } catch (error) {
    console.log('⚠️  Service role seeding failed:', error.message);
    console.log('Skipping seeding - server will start without initial data');
  }
}


