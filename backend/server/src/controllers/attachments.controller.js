const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const { v4: uuidv4 } = require('uuid');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = process.env.UPLOAD_PATH || './uploads';
    try {
      await fs.mkdir(uploadPath, { recursive: true });
      cb(null, uploadPath);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = uuidv4();
    const ext = path.extname(file.originalname);
    cb(null, `${uniqueSuffix}${ext}`);
  }
});

const fileFilter = (req, file, cb) => {
  // Allowed file types
  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'application/zip',
    'application/x-rar-compressed'
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new AppError('Invalid file type. Only images, documents, and archives are allowed.', 400), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 // 10MB
  }
});

// Get all attachments for a ticket
const getAttachmentsByTicket = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: attachments, error, count } = await supabase
    .from('attachments')
    .select(`
      id,
      file_url,
      created_at,
      uploaded_by,
      uploaded_user:uploaded_by (
        id,
        full_name,
        email
      )
    `, { count: 'exact' })
    .eq('ticket_id', ticket_id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch attachments', 500);
  }

  res.json({
    success: true,
    data: {
      attachments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get all attachments for an issue
const getAttachmentsByIssue = asyncHandler(async (req, res) => {
  const { issue_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: attachments, error, count } = await supabase
    .from('attachments')
    .select(`
      id,
      file_url,
      created_at,
      uploaded_by,
      uploaded_user:uploaded_by (
        id,
        full_name,
        email
      )
    `, { count: 'exact' })
    .eq('issue_id', issue_id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch attachments', 500);
  }

  res.json({
    success: true,
    data: {
      attachments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get attachment by ID
const getAttachmentById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: attachment, error } = await supabase
    .from('attachments')
    .select(`
      id,
      ticket_id,
      issue_id,
      file_url,
      created_at,
      uploaded_by,
      uploaded_user:uploaded_by (
        id,
        full_name,
        email
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Attachment not found', 404);
  }

  res.json({
    success: true,
    data: { attachment }
  });
});

// Upload attachment for ticket
const uploadTicketAttachment = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;
  const user_id = req.user.id;

  if (!req.file) {
    throw new AppError('No file uploaded', 400);
  }

  // Validate ticket exists
  const { data: ticket, error: ticketError } = await supabase
    .from('tickets')
    .select('id, status')
    .eq('id', ticket_id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 400);
  }

  // Check if ticket is closed (citizens can't upload to closed tickets)
  if (ticket.status === 'closed' && req.user.role === 'citizen') {
    throw new AppError('Cannot upload files to closed tickets', 400);
  }

  const file_url = `/uploads/${req.file.filename}`;

  const { data: attachment, error } = await supabase
    .from('attachments')
    .insert({
      ticket_id,
      file_url,
      uploaded_by: user_id,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      ticket_id,
      file_url,
      created_at,
      uploaded_by,
      uploaded_user:uploaded_by (
        id,
        full_name,
        email
      )
    `)
    .single();

  if (error) {
    // Clean up uploaded file if database insert fails
    try {
      await fs.unlink(req.file.path);
    } catch (unlinkError) {
      console.error('Failed to clean up uploaded file:', unlinkError);
    }
    throw new AppError('Failed to save attachment', 500);
  }

  // Log attachment upload in ticket history
  await supabase
    .from('ticket_history')
    .insert({
      ticket_id,
      action: 'Attachment uploaded',
      performed_by: user_id,
      created_at: new Date().toISOString()
    });

  res.status(201).json({
    success: true,
    message: 'Attachment uploaded successfully',
    data: { attachment }
  });
});

// Upload attachment for issue
const uploadIssueAttachment = asyncHandler(async (req, res) => {
  const { issue_id } = req.params;
  const user_id = req.user.id;

  if (!req.file) {
    throw new AppError('No file uploaded', 400);
  }

  // Validate issue exists
  const { data: issue, error: issueError } = await supabase
    .from('issues')
    .select('id, citizen_id, status')
    .eq('id', issue_id)
    .single();

  if (issueError) {
    throw new AppError('Issue not found', 400);
  }

  // Check permissions (citizens can only upload to their own issues)
  if (req.user.role === 'citizen' && issue.citizen_id !== user_id) {
    throw new AppError('You can only upload files to your own issues', 403);
  }

  // Check if issue is closed (citizens can't upload to closed issues)
  if (issue.status === 'closed' && req.user.role === 'citizen') {
    throw new AppError('Cannot upload files to closed issues', 400);
  }

  const file_url = `/uploads/${req.file.filename}`;

  const { data: attachment, error } = await supabase
    .from('attachments')
    .insert({
      issue_id,
      file_url,
      uploaded_by: user_id,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      issue_id,
      file_url,
      created_at,
      uploaded_by,
      uploaded_user:uploaded_by (
        id,
        full_name,
        email
      )
    `)
    .single();

  if (error) {
    // Clean up uploaded file if database insert fails
    try {
      await fs.unlink(req.file.path);
    } catch (unlinkError) {
      console.error('Failed to clean up uploaded file:', unlinkError);
    }
    throw new AppError('Failed to save attachment', 500);
  }

  // Log attachment upload in issue history
  await supabase
    .from('issue_history')
    .insert({
      issue_id,
      action: 'Attachment uploaded',
      performed_by: user_id,
      created_at: new Date().toISOString()
    });

  res.status(201).json({
    success: true,
    message: 'Attachment uploaded successfully',
    data: { attachment }
  });
});

// Delete attachment
const deleteAttachment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;

  // Check if attachment exists and user has permission
  const { data: attachment, error: attachmentError } = await supabase
    .from('attachments')
    .select('id, uploaded_by, file_url, ticket_id, issue_id')
    .eq('id', id)
    .single();

  if (attachmentError) {
    throw new AppError('Attachment not found', 404);
  }

  // Check permissions (user can only delete their own attachments, admins can delete any)
  if (req.user.role === 'citizen' && attachment.uploaded_by !== user_id) {
    throw new AppError('You can only delete your own attachments', 403);
  }

  // Delete file from filesystem
  try {
    const filePath = path.join(process.cwd(), attachment.file_url);
    await fs.unlink(filePath);
  } catch (unlinkError) {
    console.error('Failed to delete file from filesystem:', unlinkError);
    // Continue with database deletion even if file deletion fails
  }

  // Delete from database
  const { error: deleteError } = await supabase
    .from('attachments')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete attachment', 500);
  }

  // Log deletion in history
  if (attachment.ticket_id) {
    await supabase
      .from('ticket_history')
      .insert({
        ticket_id: attachment.ticket_id,
        action: 'Attachment deleted',
        performed_by: user_id,
        created_at: new Date().toISOString()
      });
  }

  if (attachment.issue_id) {
    await supabase
      .from('issue_history')
      .insert({
        issue_id: attachment.issue_id,
        action: 'Attachment deleted',
        performed_by: user_id,
        created_at: new Date().toISOString()
      });
  }

  res.json({
    success: true,
    message: 'Attachment deleted successfully'
  });
});

// Download attachment
const downloadAttachment = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: attachment, error } = await supabase
    .from('attachments')
    .select('file_url')
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Attachment not found', 404);
  }

  const filePath = path.join(process.cwd(), attachment.file_url);

  try {
    await fs.access(filePath);
    res.download(filePath);
  } catch (error) {
    throw new AppError('File not found on server', 404);
  }
});

// Get attachment statistics
const getAttachmentStats = asyncHandler(async (req, res) => {
  const { ticket_id, issue_id } = req.query;

  let query = supabase
    .from('attachments')
    .select('id, uploaded_by, created_at');

  if (ticket_id) {
    query = query.eq('ticket_id', ticket_id);
  }
  if (issue_id) {
    query = query.eq('issue_id', issue_id);
  }

  const { data: attachments, error } = await query;

  if (error) {
    throw new AppError('Failed to fetch attachment statistics', 500);
  }

  const userCounts = attachments.reduce((acc, attachment) => {
    acc[attachment.uploaded_by] = (acc[attachment.uploaded_by] || 0) + 1;
    return acc;
  }, {});

  res.json({
    success: true,
    data: {
      total: attachments.length,
      by_user: userCounts,
      first_upload: attachments.length > 0 ? attachments[attachments.length - 1].created_at : null,
      last_upload: attachments.length > 0 ? attachments[0].created_at : null
    }
  });
});

module.exports = {
  upload,
  getAttachmentsByTicket,
  getAttachmentsByIssue,
  getAttachmentById,
  uploadTicketAttachment,
  uploadIssueAttachment,
  deleteAttachment,
  downloadAttachment,
  getAttachmentStats
};
