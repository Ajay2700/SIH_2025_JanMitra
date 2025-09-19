const openapiSpec = {
  openapi: '3.0.3',
  info: {
    title: 'JanMitra API',
    version: '1.0.0',
    description: 'Express + Supabase API for SIH-2025 JanMitra.',
  },
  servers: [
    {
      url: 'http://localhost:{port}',
      variables: { port: { default: '4000' } },
    },
  ],
  security: [{ bearerAuth: [] }],
  components: {
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
    },
    schemas: {
      User: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          email: { type: 'string' },
          full_name: { type: 'string' },
          phone_number: { type: 'string' },
          address: { type: 'string' },
          role: { type: 'string', enum: ['citizen', 'staff', 'admin'] },
          created_at: { type: 'string', format: 'date-time' },
        },
      },
      Ticket: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          status: { type: 'string', enum: ['open','assigned','in_progress','resolved','closed'] },
          created_by: { type: 'string', format: 'uuid' },
          created_time: { type: 'string', format: 'date-time' },
          address: { type: 'string' },
          priority: { type: 'string', enum: ['low','medium','high'] },
          assigned_to: { type: 'string', format: 'uuid', nullable: true },
          eta_time: { type: 'string', format: 'date-time', nullable: true },
          up_votes: { type: 'integer' },
          description: { type: 'string' },
          photo_url: { type: 'string' },
          location: { description: 'PostGIS geometry(Point,4326) or JSON depending on schema', nullable: true },
        },
      },
      ServiceRequest: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          status: { type: 'string', enum: ['pending','in_progress','completed','cancelled'] },
          created_by: { type: 'string', format: 'uuid' },
          service_id: { type: 'string', format: 'uuid' },
          address: { type: 'string' },
          created_time: { type: 'string', format: 'date-time' },
        },
      },
      LoginRequest: {
        type: 'object',
        required: ['email','password'],
        properties: { email: { type: 'string' }, password: { type: 'string', format: 'password' } },
      },
      LoginResponse: {
        type: 'object',
        properties: {
          token: { type: 'string' },
          role: { type: 'string', enum: ['citizen','staff','admin'] },
          user: { $ref: '#/components/schemas/User' },
        },
      },
      CreateTicketRequest: {
        type: 'object',
        required: ['description'],
        properties: {
          description: { type: 'string' },
          photo_url: { type: 'string' },
          address: { type: 'string' },
          priority: { type: 'string', enum: ['low','medium','high'] },
          location: { description: 'geometry or JSON' },
        },
      },
      AssignTicketRequest: {
        type: 'object',
        required: ['assigned_to'],
        properties: { assigned_to: { type: 'string', format: 'uuid' }, eta_time: { type: 'string', format: 'date-time' } },
      },
      UpdateStatusRequest: {
        type: 'object',
        required: ['status'],
        properties: { status: { type: 'string', enum: ['open','assigned','in_progress','resolved','closed'] } },
      },
      UpdatePriorityRequest: {
        type: 'object',
        required: ['priority'],
        properties: { priority: { type: 'string', enum: ['low','medium','high'] } },
      },
      UpdateServiceRequestStatus: {
        type: 'object',
        required: ['status'],
        properties: { status: { type: 'string', enum: ['pending','in_progress','completed','cancelled'] } },
      },
    },
  },
  paths: {
    '/health': {
      get: { summary: 'Health check', responses: { '200': { description: 'OK' } } },
    },
    '/auth': {
      post: {
        summary: 'Login',
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/LoginRequest' } } } },
        responses: { '200': { description: 'OK', content: { 'application/json': { schema: { $ref: '#/components/schemas/LoginResponse' } } } }, '401': { description: 'Invalid credentials' } },
      },
    },
    '/tickets': {
      post: {
        summary: 'Create new ticket', security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateTicketRequest' } } } },
        responses: { '201': { description: 'Created', content: { 'application/json': { schema: { $ref: '#/components/schemas/Ticket' } } } } },
      },
      get: { summary: 'List my tickets', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK', content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Ticket' } } } } } } },
    },
    '/tickets/{id}': {
      get: { summary: 'Get ticket', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '200': { description: 'OK', content: { 'application/json': { schema: { $ref: '#/components/schemas/Ticket' } } } }, '404': { description: 'Not found' } } },
      delete: { summary: 'Delete ticket', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '204': { description: 'Deleted' } } },
    },
    '/tickets/{id}/updates': {
      get: { summary: 'List ticket updates', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '200': { description: 'OK' } } },
    },
    '/admin/tickets': {
      get: { summary: 'List all tickets', security: [{ bearerAuth: [] }], parameters: [
        { name: 'status', in: 'query', schema: { type: 'string' } },
        { name: 'priority', in: 'query', schema: { type: 'string' } },
        { name: 'assigned_to', in: 'query', schema: { type: 'string', format: 'uuid' } },
        { name: 'created_time', in: 'query', schema: { type: 'string', format: 'date-time' } },
      ], responses: { '200': { description: 'OK' } } },
    },
    '/admin/tickets/{id}': {
      get: { summary: 'Get ticket', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '200': { description: 'OK' } } },
    },
    '/admin/tickets/{id}/assign': {
      patch: { summary: 'Assign ticket', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/AssignTicketRequest' } } } }, responses: { '200': { description: 'OK' } } },
    },
    '/admin/tickets/{id}/status': {
      patch: { summary: 'Update ticket status', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/UpdateStatusRequest' } } } }, responses: { '200': { description: 'OK' } } },
    },
    '/admin/tickets/{id}/priority': {
      patch: { summary: 'Update ticket priority', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/UpdatePriorityRequest' } } } }, responses: { '200': { description: 'OK' } } },
    },
    '/admin/service_requests': {
      get: { summary: 'List service requests', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK' } } },
    },
    '/admin/service_requests/{id}/status': {
      patch: { summary: 'Update service request status', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/UpdateServiceRequestStatus' } } } }, responses: { '200': { description: 'OK' } } },
    },
    '/admin/staff': {
      get: { summary: 'List staff', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK' } } },
      post: { summary: 'Create staff', security: [{ bearerAuth: [] }], responses: { '201': { description: 'Created' } } },
    },
    '/admin/staff/{id}': {
      patch: { summary: 'Update staff', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '200': { description: 'OK' } } },
      delete: { summary: 'Delete staff', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }], responses: { '204': { description: 'Deleted' } } },
    },
    '/admin/analytics/tickets': {
      get: { summary: 'Ticket summary', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK' } } },
    },
    '/admin/analytics/departments': {
      get: { summary: 'Department-wise performance', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK' } } },
    },
    '/admin/analytics/trends': {
      get: { summary: 'Trending issues and hotspots', security: [{ bearerAuth: [] }], responses: { '200': { description: 'OK' } } },
    },
  },
};

export default openapiSpec;


