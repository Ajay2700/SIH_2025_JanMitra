import dayjs from 'dayjs';
import { supabase } from '../config/supabase.js';

// Tickets Admin
export async function adminListTickets(req, res) {
  const { status, priority, assigned_to, created_at, department_id, ticket_type } = req.query;
  let query = supabase.from('tickets').select(`
    *,
    ticket_categories(name, description),
    departments(name, department_code),
    assigned_user:assigned_to(id, name, email),
    user:user_id(id, name, email)
  `);
  if (status) query = query.eq('status', status);
  if (priority) query = query.eq('priority', priority);
  if (assigned_to) query = query.eq('assigned_to', assigned_to);
  if (created_at) query = query.gte('created_at', created_at);
  if (department_id) query = query.eq('department_id', department_id);
  if (ticket_type) query = query.eq('ticket_type', ticket_type);
  const { data, error } = await query.order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminGetTicket(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('tickets')
    .select(`
      *,
      ticket_categories(name, description),
      departments(name, department_code),
      assigned_user:assigned_to(id, name, email),
      user:user_id(id, name, email),
      ticket_comments(content, created_at, user_name, is_official_response),
      ticket_attachments(file_name, file_url, file_type),
      ticket_history(action_type, old_value, new_value, changed_by, notes, created_at)
    `)
    .eq('id', id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
}

export async function adminAssignTicket(req, res) {
  const { id } = req.params;
  const { assigned_to, department_id } = req.body || {};
  if (!assigned_to) return res.status(400).json({ error: 'assigned_to required' });
  const { data, error } = await supabase
    .from('tickets')
    .update({ assigned_to, department_id, status: 'in_progress' })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminUpdateTicketStatus(req, res) {
  const { id } = req.params;
  const { status } = req.body || {};
  if (!['open','in_progress','pending','resolved','closed','rejected','escalated','forwarded'].includes(status)) {
    return res.status(400).json({ error: 'invalid status' });
  }
  const { data, error } = await supabase
    .from('tickets')
    .update({ status })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminUpdateTicketPriority(req, res) {
  const { id } = req.params;
  const { priority } = req.body || {};
  if (!['low','medium','high','urgent','critical'].includes(priority)) {
    return res.status(400).json({ error: 'invalid priority' });
  }
  const { data, error } = await supabase
    .from('tickets')
    .update({ priority })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

// Departments Management
export async function adminListDepartments(_req, res) {
  const { data, error } = await supabase
    .from('departments')
    .select(`
      *,
      head:head_id(id, name, email)
    `)
    .order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminCreateDepartment(req, res) {
  const { name, description, department_code, jurisdiction, contact_email, contact_phone } = req.body || {};
  if (!name || !department_code) return res.status(400).json({ error: 'name and department_code required' });
  
  const { data, error } = await supabase
    .from('departments')
    .insert({ name, description, department_code, jurisdiction, contact_email, contact_phone })
    .select('*')
    .single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function adminUpdateDepartment(req, res) {
  const { id } = req.params;
  const { name, description, department_code, jurisdiction, contact_email, contact_phone, head_id } = req.body || {};
  
  const { data, error } = await supabase
    .from('departments')
    .update({ name, description, department_code, jurisdiction, contact_email, contact_phone, head_id })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Department not found' });
  return res.json(data);
}

// Staff Management
export async function adminListStaff(_req, res) {
  const { data, error } = await supabase
    .from('users')
    .select(`
      id, email, name, phone, address, user_type, department_id, 
      designation, employee_id, created_at,
      departments(name, department_code)
    `)
    .eq('user_type', 'staff');
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminCreateStaff(req, res) {
  const { email, password, name, phone, address, department_id, designation, employee_id } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'email and password required' });
  const { data: existing, error: selErr } = await supabase.from('users').select('id').eq('email', email).maybeSingle();
  if (selErr) return res.status(500).json({ error: selErr.message });
  if (existing) return res.status(409).json({ error: 'email exists' });
  const { default: bcrypt } = await import('bcryptjs');
  const hashed = await bcrypt.hash(password, 10);
  const { data, error } = await supabase
    .from('users')
    .insert({ 
      id: crypto.randomUUID(),
      email, 
      password: hashed, 
      name, 
      phone, 
      address, 
      department_id,
      designation,
      employee_id,
      user_type: 'staff' 
    })
    .select('id,email,name,phone,address,user_type,department_id,designation,employee_id')
    .single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function adminUpdateStaff(req, res) {
  const { id } = req.params;
  const { name, phone, address, department_id, designation, employee_id } = req.body || {};
  const { data, error } = await supabase
    .from('users')
    .update({ name, phone, address, department_id, designation, employee_id })
    .eq('id', id)
    .eq('user_type', 'staff')
    .select('id,email,name,phone,address,user_type,department_id,designation,employee_id')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
}

export async function adminDeleteStaff(req, res) {
  const { id } = req.params;
  const { error } = await supabase.from('users').delete().eq('id', id).eq('user_type', 'staff');
  if (error) return res.status(500).json({ error: error.message });
  return res.status(204).send();
}

// Analytics
export async function adminAnalyticsTickets(_req, res) {
  try {
    // Get ticket counts by status
    const { data: statusCounts, error: statusError } = await supabase
      .from('tickets')
      .select('status')
      .then(result => {
        if (result.error) return result;
        const counts = result.data.reduce((acc, ticket) => {
          acc[ticket.status] = (acc[ticket.status] || 0) + 1;
          return acc;
        }, {});
        return { data: counts, error: null };
      });

    if (statusError) return res.status(500).json({ error: statusError.message });

    // Get total tickets
    const { count: totalTickets, error: countError } = await supabase
      .from('tickets')
      .select('*', { count: 'exact', head: true });

    if (countError) return res.status(500).json({ error: countError.message });

    return res.json({
      total_tickets: totalTickets,
      status_counts: statusCounts
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}

export async function adminAnalyticsDepartments(_req, res) {
  try {
    const { data, error } = await supabase
      .from('departments')
      .select(`
        id,
        name,
        department_code,
        tickets:tickets(id, status, resolved_at)
      `);

    if (error) return res.status(500).json({ error: error.message });

    const departmentStats = data.map(dept => ({
      id: dept.id,
      name: dept.name,
      department_code: dept.department_code,
      total_tickets: dept.tickets.length,
      resolved_tickets: dept.tickets.filter(t => t.status === 'resolved').length,
      open_tickets: dept.tickets.filter(t => ['open', 'in_progress', 'pending'].includes(t.status)).length
    }));

    return res.json(departmentStats);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}

export async function adminAnalyticsTrends(_req, res) {
  try {
    // Get tickets created in the last 30 days grouped by date
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const { data, error } = await supabase
      .from('tickets')
      .select('created_at, ticket_type, priority')
      .gte('created_at', thirtyDaysAgo.toISOString())
      .order('created_at', { ascending: true });

    if (error) return res.status(500).json({ error: error.message });

    // Group by date and type
    const trends = data.reduce((acc, ticket) => {
      const date = ticket.created_at.split('T')[0];
      if (!acc[date]) {
        acc[date] = { date, total: 0, by_type: {}, by_priority: {} };
      }
      acc[date].total++;
      acc[date].by_type[ticket.ticket_type] = (acc[date].by_type[ticket.ticket_type] || 0) + 1;
      acc[date].by_priority[ticket.priority] = (acc[date].by_priority[ticket.priority] || 0) + 1;
      return acc;
    }, {});

    return res.json(Object.values(trends));
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}


