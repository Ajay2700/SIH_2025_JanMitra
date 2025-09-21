const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Get all system settings
const getAllSettings = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, search } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('system_settings')
    .select('*', { count: 'exact' });

  if (search) {
    query = query.or(`key.ilike.%${search}%,value.ilike.%${search}%`);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: settings, error, count } = await query;

  if (error) {
    console.error('Supabase error fetching system settings:', error);
    // Return empty data instead of throwing error to allow frontend to load
    return res.json({
      success: true,
      data: {
        settings: [],
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: 0,
          pages: 0
        }
      }
    });
  }

  res.json({
    success: true,
    data: {
      settings,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get setting by key
const getSettingByKey = asyncHandler(async (req, res) => {
  const { key } = req.params;

  const { data: setting, error } = await supabase
    .from('system_settings')
    .select('*')
    .eq('key', key)
    .single();

  if (error) {
    throw new AppError('Setting not found', 404);
  }

  res.json({
    success: true,
    data: { setting }
  });
});

// Get multiple settings by keys
const getSettingsByKeys = asyncHandler(async (req, res) => {
  const { keys } = req.body;

  if (!Array.isArray(keys) || keys.length === 0) {
    throw new AppError('Keys array is required', 400);
  }

  const { data: settings, error } = await supabase
    .from('system_settings')
    .select('*')
    .in('key', keys);

  if (error) {
    throw new AppError('Failed to fetch settings', 500);
  }

  // Convert to key-value object
  const settingsObj = settings.reduce((acc, setting) => {
    acc[setting.key] = setting.value;
    return acc;
  }, {});

  res.json({
    success: true,
    data: { settings: settingsObj }
  });
});

// Create new setting
const createSetting = asyncHandler(async (req, res) => {
  const { key, value } = req.body;

  // Check if setting already exists
  const { data: existingSetting, error: existingError } = await supabase
    .from('system_settings')
    .select('id')
    .eq('key', key)
    .single();

  if (existingSetting) {
    throw new AppError('Setting with this key already exists', 409);
  }

  const { data: setting, error } = await supabase
    .from('system_settings')
    .insert({
      key,
      value,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to create setting', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Setting created successfully',
    data: { setting }
  });
});

// Update setting
const updateSetting = asyncHandler(async (req, res) => {
  const { key } = req.params;
  const { value } = req.body;

  // Check if setting exists
  const { data: existingSetting, error: existingError } = await supabase
    .from('system_settings')
    .select('id')
    .eq('key', key)
    .single();

  if (existingError) {
    throw new AppError('Setting not found', 404);
  }

  const { data: setting, error } = await supabase
    .from('system_settings')
    .update({
      value,
      updated_at: new Date().toISOString()
    })
    .eq('key', key)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update setting', 500);
  }

  res.json({
    success: true,
    message: 'Setting updated successfully',
    data: { setting }
  });
});

// Update multiple settings
const updateMultipleSettings = asyncHandler(async (req, res) => {
  const { settings } = req.body;

  if (!settings || typeof settings !== 'object') {
    throw new AppError('Settings object is required', 400);
  }

  const updates = Object.entries(settings).map(([key, value]) => ({
    key,
    value,
    updated_at: new Date().toISOString()
  }));

  const { data: updatedSettings, error } = await supabase
    .from('system_settings')
    .upsert(updates)
    .select();

  if (error) {
    throw new AppError('Failed to update settings', 500);
  }

  res.json({
    success: true,
    message: `${updatedSettings.length} settings updated successfully`,
    data: { settings: updatedSettings }
  });
});

// Delete setting
const deleteSetting = asyncHandler(async (req, res) => {
  const { key } = req.params;

  // Check if setting exists
  const { data: setting, error: settingError } = await supabase
    .from('system_settings')
    .select('id')
    .eq('key', key)
    .single();

  if (settingError) {
    throw new AppError('Setting not found', 404);
  }

  const { error: deleteError } = await supabase
    .from('system_settings')
    .delete()
    .eq('key', key);

  if (deleteError) {
    throw new AppError('Failed to delete setting', 500);
  }

  res.json({
    success: true,
    message: 'Setting deleted successfully'
  });
});

// Get application configuration
const getAppConfig = asyncHandler(async (req, res) => {
  // Get common application settings
  const commonKeys = [
    'app_name',
    'app_version',
    'maintenance_mode',
    'max_file_size',
    'allowed_file_types',
    'email_notifications',
    'sms_notifications',
    'default_ticket_priority',
    'auto_assign_tickets',
    'sla_enabled',
    'feedback_enabled',
    'analytics_enabled'
  ];

  const { data: settings, error } = await supabase
    .from('system_settings')
    .select('key, value')
    .in('key', commonKeys);

  if (error) {
    throw new AppError('Failed to fetch application configuration', 500);
  }

  // Convert to key-value object with default values
  const config = {
    app_name: 'JanMitra',
    app_version: '1.0.0',
    maintenance_mode: false,
    max_file_size: '10485760', // 10MB
    allowed_file_types: 'image/*,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,text/plain',
    email_notifications: true,
    sms_notifications: false,
    default_ticket_priority: 'medium',
    auto_assign_tickets: false,
    sla_enabled: true,
    feedback_enabled: true,
    analytics_enabled: true
  };

  settings.forEach(setting => {
    config[setting.key] = setting.value;
  });

  res.json({
    success: true,
    data: { config }
  });
});

// Get system health status
const getSystemHealth = asyncHandler(async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    services: {}
  };

  try {
    // Check database connection
    const { data: dbCheck, error: dbError } = await supabase
      .from('system_settings')
      .select('id')
      .limit(1);

    health.services.database = {
      status: dbError ? 'unhealthy' : 'healthy',
      error: dbError?.message || null
    };

    // Check if any service is unhealthy
    const unhealthyServices = Object.values(health.services).filter(service => service.status === 'unhealthy');
    if (unhealthyServices.length > 0) {
      health.status = 'unhealthy';
    }

  } catch (error) {
    health.status = 'unhealthy';
    health.error = error.message;
  }

  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json({
    success: health.status === 'healthy',
    data: health
  });
});

// Get system statistics
const getSystemStats = asyncHandler(async (req, res) => {
  const { data: stats, error } = await supabase
    .from('system_settings')
    .select('key, value')
    .in('key', [
      'total_tickets',
      'total_issues',
      'total_users',
      'total_departments',
      'total_categories',
      'system_uptime',
      'last_backup',
      'version'
    ]);

  if (error) {
    throw new AppError('Failed to fetch system statistics', 500);
  }

  // Convert to key-value object
  const systemStats = stats.reduce((acc, stat) => {
    acc[stat.key] = stat.value;
    return acc;
  }, {});

  res.json({
    success: true,
    data: { stats: systemStats }
  });
});

// Reset settings to defaults
const resetToDefaults = asyncHandler(async (req, res) => {
  const defaultSettings = [
    { key: 'app_name', value: 'JanMitra' },
    { key: 'app_version', value: '1.0.0' },
    { key: 'maintenance_mode', value: 'false' },
    { key: 'max_file_size', value: '10485760' },
    { key: 'allowed_file_types', value: 'image/*,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,text/plain' },
    { key: 'email_notifications', value: 'true' },
    { key: 'sms_notifications', value: 'false' },
    { key: 'default_ticket_priority', value: 'medium' },
    { key: 'auto_assign_tickets', value: 'false' },
    { key: 'sla_enabled', value: 'true' },
    { key: 'feedback_enabled', value: 'true' },
    { key: 'analytics_enabled', value: 'true' }
  ];

  const { data: settings, error } = await supabase
    .from('system_settings')
    .upsert(defaultSettings.map(setting => ({
      ...setting,
      updated_at: new Date().toISOString()
    })))
    .select();

  if (error) {
    throw new AppError('Failed to reset settings to defaults', 500);
  }

  res.json({
    success: true,
    message: 'Settings reset to defaults successfully',
    data: { settings }
  });
});

module.exports = {
  getAllSettings,
  getSettingByKey,
  getSettingsByKeys,
  createSetting,
  updateSetting,
  updateMultipleSettings,
  deleteSetting,
  getAppConfig,
  getSystemHealth,
  getSystemStats,
  resetToDefaults
};
