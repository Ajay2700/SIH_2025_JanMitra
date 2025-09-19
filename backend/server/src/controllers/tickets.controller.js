import { supabase } from '../config/supabase.js';

export async function createTicket(req, res) {
  const userId = req.user.id;
  const { description, photo_url, address, priority, location } = req.body || {};
  if (!description) return res.status(400).json({ error: 'description required' });
  const payload = { description, photo_url, address, priority, created_by: userId };
  if (location && typeof location === 'object') {
    payload.location = location; // Expecting PostGIS geometry object via PostgREST shape if enabled
  }
  const { data, error } = await supabase.from('tickets').insert(payload).select('*').single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function listMyTickets(req, res) {
  const userId = req.user.id;
  const { data, error } = await supabase
    .from('tickets')
    .select('*')
    .eq('created_by', userId)
    .order('created_time', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function getTicket(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  const { data, error } = await supabase.from('tickets').select('*').eq('id', id).maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Not found' });
  if (data.created_by !== userId && req.user.role === 'citizen') return res.status(403).json({ error: 'Forbidden' });
  return res.json(data);
}

export async function deleteTicket(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  const { data: ticket, error: selErr } = await supabase.from('tickets').select('id,status,created_by,assigned_to').eq('id', id).maybeSingle();
  if (selErr) return res.status(500).json({ error: selErr.message });
  if (!ticket) return res.status(404).json({ error: 'Not found' });
  if (ticket.created_by !== userId) return res.status(403).json({ error: 'Forbidden' });
  if (ticket.status !== 'open' || ticket.assigned_to) return res.status(400).json({ error: 'Cannot delete after assignment' });
  const { error } = await supabase.from('tickets').delete().eq('id', id);
  if (error) return res.status(500).json({ error: error.message });
  return res.status(204).send();
}

export async function listTicketUpdates(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('ticket_updates')
    .select('*')
    .eq('ticket_id', id)
    .order('created_at', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}


