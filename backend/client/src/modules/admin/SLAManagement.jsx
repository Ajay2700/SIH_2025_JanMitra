import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { slaAPI, categoriesAPI } from '../../services/api.js'

export default function SLAManagement() {
  const { token } = useAuth()
  const [slas, setSlas] = useState([])
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showModal, setShowModal] = useState(false)
  const [editingSLA, setEditingSLA] = useState(null)
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    category_id: '',
    response_time_hours: 24,
    resolution_time_hours: 72,
    escalation_time_hours: 48,
    is_active: true
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    setError('')
    try {
      const [slasData, categoriesData] = await Promise.all([
        slaAPI.getAll(token),
        categoriesAPI.getAll(token)
      ])
      const slasArray = slasData?.data?.slas || slasData?.data || slasData || []
      const categoriesArray = categoriesData?.data?.categories || categoriesData?.data || categoriesData || []
      setSlas(Array.isArray(slasArray) ? slasArray : [])
      setCategories(Array.isArray(categoriesArray) ? categoriesArray : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editingSLA) {
        await slaAPI.update(editingSLA.id, formData, token)
      } else {
        await slaAPI.create(formData, token)
      }
      setShowModal(false)
      setEditingSLA(null)
      setFormData({
        name: '',
        description: '',
        category_id: '',
        response_time_hours: 24,
        resolution_time_hours: 72,
        escalation_time_hours: 48,
        is_active: true
      })
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleEdit = (sla) => {
    setEditingSLA(sla)
    setFormData({
      name: sla.name || '',
      description: sla.description || '',
      category_id: sla.category_id || '',
      response_time_hours: sla.response_time_hours || 24,
      resolution_time_hours: sla.resolution_time_hours || 72,
      escalation_time_hours: sla.escalation_time_hours || 48,
      is_active: sla.is_active !== false
    })
    setShowModal(true)
  }

  const handleDelete = async (slaId) => {
    if (window.confirm('Are you sure you want to delete this SLA configuration?')) {
      try {
        await slaAPI.delete(slaId, token)
        loadData()
      } catch (err) {
        setError(err.message)
      }
    }
  }

  const handleCheckBreaches = async () => {
    try {
      await slaAPI.checkBreaches(token)
      setError('')
      // You could add a success message here
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      category_id: '',
      response_time_hours: 24,
      resolution_time_hours: 72,
      escalation_time_hours: 48,
      is_active: true
    })
    setEditingSLA(null)
  }

  const formatTime = (hours) => {
    if (hours < 24) {
      return `${hours}h`
    } else if (hours < 168) {
      return `${Math.round(hours / 24)}d`
    } else {
      return `${Math.round(hours / 168)}w`
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">SLA Management</h1>
          <p className="mt-1 text-sm text-gray-500">Manage Service Level Agreements and response times</p>
        </div>
        <div className="flex space-x-3">
          <button
            onClick={handleCheckBreaches}
            className="bg-yellow-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-yellow-700"
          >
            Check Breaches
          </button>
          <button
            onClick={() => {
              resetForm()
              setShowModal(true)
            }}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
          >
            Add SLA
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-sm text-red-700">{error}</div>
        </div>
      )}

      {/* SLA Table */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    SLA Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Category
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Response Time
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Resolution Time
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Escalation Time
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500">
                      Loading SLA configurations...
                    </td>
                  </tr>
                ) : slas.length === 0 ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500">
                      No SLA configurations found
                    </td>
                  </tr>
                ) : (
                  (slas || []).map((sla) => (
                    <tr key={sla.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{sla.name}</div>
                        <div className="text-sm text-gray-500 max-w-xs truncate">
                          {sla.description || 'No description'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {categories.find(c => c.id === sla.category_id)?.name || 'No category'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                          {formatTime(sla.response_time_hours)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                          {formatTime(sla.resolution_time_hours)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">
                          {formatTime(sla.escalation_time_hours)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          sla.is_active !== false ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                          {sla.is_active !== false ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => handleEdit(sla)}
                          className="text-indigo-600 hover:text-indigo-900 mr-3"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDelete(sla.id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {editingSLA ? 'Edit SLA' : 'Add New SLA'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Name</label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows={3}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Category</label>
                  <select
                    value={formData.category_id}
                    onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  >
                    <option value="">Select Category</option>
                    {(categories || []).map((cat) => (
                      <option key={cat.id} value={cat.id}>
                        {cat.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Response Time (hours)</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={formData.response_time_hours}
                    onChange={(e) => setFormData({ ...formData, response_time_hours: parseInt(e.target.value) })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Resolution Time (hours)</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={formData.resolution_time_hours}
                    onChange={(e) => setFormData({ ...formData, resolution_time_hours: parseInt(e.target.value) })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Escalation Time (hours)</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={formData.escalation_time_hours}
                    onChange={(e) => setFormData({ ...formData, escalation_time_hours: parseInt(e.target.value) })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="is_active"
                    checked={formData.is_active}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                    className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  />
                  <label htmlFor="is_active" className="ml-2 block text-sm text-gray-900">
                    Active
                  </label>
                </div>
                <div className="flex justify-end space-x-3">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
                  >
                    {editingSLA ? 'Update' : 'Create'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
