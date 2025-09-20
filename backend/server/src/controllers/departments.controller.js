import { supabase } from '../config/supabase.js';

export async function listDepartments(req, res) {
  const { is_active } = req.query;
  let query = supabase
    .from('departments')
    .select(`
      *,
      head:head_id(id, name, email, designation),
      parent_department:parent_department_id(name, department_code)
    `);
    
  if (is_active !== undefined) {
    query = query.eq('is_active', is_active === 'true');
  }
  
  const { data, error } = await query.order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function getDepartment(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('departments')
    .select(`
      *,
      head:head_id(id, name, email, designation),
      parent_department:parent_department_id(name, department_code),
      child_departments:departments!parent_department_id(id, name, department_code)
    `)
    .eq('id', id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Department not found' });
  return res.json(data);
}

export async function getDepartmentStaff(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('users')
    .select(`
      id, name, email, phone, designation, employee_id, user_type,
      departments(name, department_code)
    `)
    .eq('department_id', id)
    .eq('user_type', 'staff');
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function getDepartmentTickets(req, res) {
  const { id } = req.params;
  const { status, priority, created_at } = req.query;
  
  let query = supabase
    .from('tickets')
    .select(`
      *,
      ticket_categories(name, description),
      assigned_user:assigned_to(id, name, email),
      user:user_id(id, name, email)
    `)
    .eq('department_id', id);
    
  if (status) query = query.eq('status', status);
  if (priority) query = query.eq('priority', priority);
  if (created_at) query = query.gte('created_at', created_at);
  
  const { data, error } = await query.order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}
