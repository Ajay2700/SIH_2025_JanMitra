#!/usr/bin/env node

import { supabase, supabaseAdmin } from './src/config/supabase.js';

async function testSetup() {
  console.log('🧪 Testing Supabase Setup...\n');

  try {
    // Test 1: Check if we can connect to Supabase
    console.log('1. Testing Supabase connection...');
    const { data: testData, error: testError } = await supabaseAdmin
      .from('departments')
      .select('count')
      .limit(1);
    
    if (testError) {
      console.log('❌ Connection failed:', testError.message);
      return;
    }
    console.log('✅ Supabase connection successful');

    // Test 2: Check if tables exist
    console.log('\n2. Checking if tables exist...');
    const tables = ['users', 'departments', 'ticket_categories', 'tickets'];
    
    for (const table of tables) {
      const { error } = await supabaseAdmin
        .from(table)
        .select('count')
        .limit(1);
      
      if (error) {
        console.log(`❌ Table '${table}' not found:`, error.message);
      } else {
        console.log(`✅ Table '${table}' exists`);
      }
    }

    // Test 3: Check if departments are seeded
    console.log('\n3. Checking seeded data...');
    const { data: departments, error: deptError } = await supabaseAdmin
      .from('departments')
      .select('name, department_code');
    
    if (deptError) {
      console.log('❌ Failed to fetch departments:', deptError.message);
    } else {
      console.log(`✅ Found ${departments.length} departments:`);
      departments.forEach(dept => {
        console.log(`   - ${dept.name} (${dept.department_code})`);
      });
    }

    // Test 4: Check if categories are seeded
    const { data: categories, error: catError } = await supabaseAdmin
      .from('ticket_categories')
      .select('name, sla_hours');
    
    if (catError) {
      console.log('❌ Failed to fetch categories:', catError.message);
    } else {
      console.log(`✅ Found ${categories.length} ticket categories:`);
      categories.forEach(cat => {
        console.log(`   - ${cat.name} (SLA: ${cat.sla_hours}h)`);
      });
    }

    console.log('\n🎉 Setup test completed successfully!');
    console.log('\n📋 Next steps:');
    console.log('1. Run the SQL script in your Supabase SQL editor');
    console.log('2. Set up your environment variables (.env file)');
    console.log('3. Start the server with: npm run dev');

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

testSetup();

