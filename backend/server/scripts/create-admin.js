#!/usr/bin/env node

/**
 * Admin User Creation Script
 * 
 * This script creates an admin user directly in the database
 * Usage: node scripts/create-admin.js [email] [password] [full_name]
 * 
 * Example: node scripts/create-admin.js admin@example.com admin123 "Admin User"
 */

const { supabase } = require('../src/config/supabase');
const bcrypt = require('bcryptjs');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

async function createAdminUser(email, password, fullName) {
  try {
    console.log('🔍 Checking if user already exists...');
    
    // Check if user already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id, email, role')
      .eq('email', email)
      .single();

    if (existingUser) {
      console.log(`❌ User with email ${email} already exists with role: ${existingUser.role}`);
      
      if (existingUser.role === 'admin' || existingUser.role === 'super_admin') {
        console.log('✅ User is already an admin!');
        return;
      }
      
      // Ask if user wants to upgrade existing user to admin
      const answer = await askQuestion(`Do you want to upgrade this user to admin? (y/n): `);
      if (answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes') {
        const { error: updateError } = await supabase
          .from('users')
          .update({ 
            role: 'admin',
            updated_at: new Date().toISOString()
          })
          .eq('id', existingUser.id);

        if (updateError) {
          console.error('❌ Error updating user role:', updateError.message);
          return;
        }
        
        console.log('✅ User role updated to admin successfully!');
        return;
      } else {
        console.log('❌ Operation cancelled.');
        return;
      }
    }

    console.log('🔐 Hashing password...');
    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    console.log('💾 Creating admin user in database...');
    // Create admin user
    const { data: userData, error: userError } = await supabase
      .from('users')
      .insert({
        email,
        password_hash: hashedPassword,
        full_name: fullName,
        role: 'admin',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (userError) {
      console.error('❌ Error creating admin user:', userError.message);
      return;
    }

    console.log('✅ Admin user created successfully!');
    console.log('📋 User Details:');
    console.log(`   ID: ${userData.id}`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Name: ${userData.full_name}`);
    console.log(`   Role: ${userData.role}`);
    console.log(`   Created: ${userData.created_at}`);
    
  } catch (error) {
    console.error('❌ Unexpected error:', error.message);
  }
}

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function main() {
  console.log('🚀 JanMitra Admin User Creation Script');
  console.log('=====================================\n');

  // Get command line arguments
  const args = process.argv.slice(2);
  
  let email, password, fullName;

  if (args.length >= 3) {
    // Use command line arguments
    email = args[0];
    password = args[1];
    fullName = args[2];
  } else {
    // Interactive mode
    console.log('Enter admin user details:');
    email = await askQuestion('Email: ');
    password = await askQuestion('Password: ');
    fullName = await askQuestion('Full Name: ');
  }

  // Validate inputs
  if (!email || !password || !fullName) {
    console.error('❌ All fields are required!');
    process.exit(1);
  }

  if (password.length < 6) {
    console.error('❌ Password must be at least 6 characters long!');
    process.exit(1);
  }

  await createAdminUser(email, password, fullName);
  
  rl.close();
  process.exit(0);
}

// Handle script termination
process.on('SIGINT', () => {
  console.log('\n❌ Script cancelled by user');
  rl.close();
  process.exit(1);
});

main().catch((error) => {
  console.error('❌ Script failed:', error.message);
  rl.close();
  process.exit(1);
});
