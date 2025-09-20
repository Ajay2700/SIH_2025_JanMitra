import { supabase } from '../config/supabase.js';

export async function createTicket(req, res) {
  const userId = req.user.id;
  const { 
    title, 
    description, 
    priority, 
    ticket_type, 
    category_id, 
    sub_category,
    location_address,
    district,
    state,
    pin_code,
    latitude,
    longitude,
    ward_number,
    constituency,
    attachments
  } = req.body || {};
  
  if (!title || !description) return res.status(400).json({ error: 'title and description required' });
  
  // Generate ticket number
  const ticketNumber = `TKT-${Date.now()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}`;
  
  const payload = { 
    ticket_number: ticketNumber,
    title, 
    description, 
    priority: priority || 'medium',
    ticket_type: ticket_type || 'complaint',
    category_id,
    sub_category,
    user_id: userId,
    location_address,
    district,
    state,
    pin_code,
    latitude,
    longitude,
    ward_number,
    constituency
  };
  
  const { data, error } = await supabase.from('tickets').insert(payload).select('*').single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function listMyTickets(req, res) {
  const userId = req.user.id;
  const { data, error } = await supabase
    .from('tickets')
    .select(`
      *,
      ticket_categories(name, description),
      departments(name, department_code),
      assigned_user:assigned_to(id, name, email)
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function getTicket(req, res) {
  const userId = req.user.id;
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
      ticket_attachments(file_name, file_url, file_type)
    `)
    .eq('id', id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  if (data.user_id !== userId && req.user.user_type === 'citizen') return res.status(403).json({ error: 'Forbidden' });
  return res.json(data);
}

export async function deleteTicket(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  const { data: ticket, error: selErr } = await supabase.from('tickets').select('id,status,user_id,assigned_to').eq('id', id).maybeSingle();
  if (selErr) return res.status(500).json({ error: selErr.message });
  if (!ticket) return res.status(404).json({ error: 'Not found' });
  if (ticket.user_id !== userId) return res.status(403).json({ error: 'Forbidden' });
  if (ticket.status !== 'open' || ticket.assigned_to) return res.status(400).json({ error: 'Cannot delete after assignment' });
  const { error } = await supabase.from('tickets').delete().eq('id', id);
  if (error) return res.status(500).json({ error: error.message });
  return res.status(204).send();
}

export async function listTicketComments(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('ticket_comments')
    .select(`
      *,
      user:user_id(id, name, email)
    `)
    .eq('ticket_id', id)
    .order('created_at', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function addTicketComment(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  const { content, comment_type = 'public' } = req.body || {};
  
  if (!content) return res.status(400).json({ error: 'content required' });
  
  const { data, error } = await supabase
    .from('ticket_comments')
    .insert({
      ticket_id: id,
      user_id: userId,
      content,
      comment_type,
      user_name: req.user.name,
      user_role: req.user.user_type
    })
    .select('*')
    .single();
    
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}


