import { supabase } from '../config/supabase.js';

export async function listCategories(req, res) {
  const { department_id } = req.query;
  let query = supabase
    .from('ticket_categories')
    .select(`
      *,
      departments(name, department_code)
    `)
    .eq('is_active', true);
    
  if (department_id) {
    query = query.eq('department_id', department_id);
  }
  
  const { data, error } = await query.order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
}

export async function getCategory(req, res) {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('ticket_categories')
    .select(`
      *,
      departments(name, department_code),
      parent_category:ticket_categories(name, description)
    `)
    .eq('id', id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Category not found' });
  return res.json(data);
}

export async function createCategory(req, res) {
  const { name, description, department_id, parent_category_id, sla_hours } = req.body || {};
  if (!name || !department_id) return res.status(400).json({ error: 'name and department_id required' });
  
  const { data, error } = await supabase
    .from('ticket_categories')
    .insert({
      name,
      description,
      department_id,
      parent_category_id,
      sla_hours: sla_hours || 48
    })
    .select('*')
    .single();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
}

export async function updateCategory(req, res) {
  const { id } = req.params;
  const { name, description, department_id, parent_category_id, sla_hours, is_active } = req.body || {};
  
  const { data, error } = await supabase
    .from('ticket_categories')
    .update({
      name,
      description,
      department_id,
      parent_category_id,
      sla_hours,
      is_active
    })
    .eq('id', id)
    .select('*')
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'Category not found' });
  return res.json(data);
}

export async function deleteCategory(req, res) {
  const { id } = req.params;
  const { error } = await supabase.from('ticket_categories').delete().eq('id', id);
  if (error) return res.status(500).json({ error: error.message });
  return res.status(204).send();
}
