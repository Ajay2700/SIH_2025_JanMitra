import dayjs from 'dayjs';
import { supabase } from '../config/supabase.js';

// Tickets Admin
export async function adminListTickets(req, res) {
  const { status, priority, assigned_to, created_time } = req.query;
  let query = supabase.from('tickets').select('*');
  if (status) query = query.eq('status', status);
  if (priority) query = query.eq('priority', priority);
  if (assigned_to) query = query.eq('assigned_to', assigned_to);
  if (created_time) query = query.gte('created_time', created_time);
  const { data, error } = await query.order('created_time', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminGetTicket(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase.from('tickets').select('*').eq('id', id).maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
}

export async function adminAssignTicket(req, res) {
  const { id } = req.params;
  const { assigned_to, eta_time } = req.body || {};
  if (!assigned_to) return res.status(400).json({ error: 'assigned_to required' });
  const { data, error } = await supabase
    .from('tickets')
    .update({ assigned_to, eta_time, status: 'assigned' })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminUpdateTicketStatus(req, res) {
  const { id } = req.params;
  const { status } = req.body || {};
  if (!['open','assigned','in_progress','resolved','closed'].includes(status)) {
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
  if (!['low','medium','high'].includes(priority)) {
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

// Service Requests
export async function adminListServiceRequests(_req, res) {
  const { data, error } = await supabase.from('service_requests').select('*').order('created_time', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminUpdateServiceRequestStatus(req, res) {
  const { id } = req.params;
  const { status } = req.body || {};
  if (!['pending','in_progress','completed','cancelled'].includes(status)) {
    return res.status(400).json({ error: 'invalid status' });
  }
  const { data, error } = await supabase
    .from('service_requests')
    .update({ status })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

// Staff Management
export async function adminListStaff(_req, res) {
  const { data, error } = await supabase.from('users').select('id,email,full_name,phone_number,address,role,created_at').eq('role', 'staff');
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminCreateStaff(req, res) {
  const { email, password, full_name, phone_number, address } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'email and password required' });
  const { data: existing, error: selErr } = await supabase.from('users').select('id').eq('email', email).maybeSingle();
  if (selErr) return res.status(500).json({ error: selErr.message });
  if (existing) return res.status(409).json({ error: 'email exists' });
  const { default: bcrypt } = await import('bcryptjs');
  const hashed = await bcrypt.hash(password, 10);
  const { data, error } = await supabase
    .from('users')
    .insert({ email, password: hashed, full_name, phone_number, address, role: 'staff' })
    .select('id,email,full_name,phone_number,address,role')
    .single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function adminUpdateStaff(req, res) {
  const { id } = req.params;
  const { full_name, phone_number, address } = req.body || {};
  const { data, error } = await supabase
    .from('users')
    .update({ full_name, phone_number, address })
    .eq('id', id)
    .eq('role', 'staff')
    .select('id,email,full_name,phone_number,address,role')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
}

export async function adminDeleteStaff(req, res) {
  const { id } = req.params;
  const { error } = await supabase.from('users').delete().eq('id', id).eq('role', 'staff');
  if (error) return res.status(500).json({ error: error.message });
  return res.status(204).send();
}

// Analytics
export async function adminAnalyticsTickets(_req, res) {
  const { data: totals, error: err1 } = await supabase.rpc('tickets_summary');
  if (err1) return res.status(500).json({ error: err1.message });
  return res.json(totals);
}

export async function adminAnalyticsDepartments(_req, res) {
  const { data, error } = await supabase.rpc('departments_performance');
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function adminAnalyticsTrends(_req, res) {
  const { data, error } = await supabase.rpc('trending_issues');
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}


