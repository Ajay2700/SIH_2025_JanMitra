import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { settingsAPI } from '../../services/api.js'

export default function SettingsManagement() {
  const { token } = useAuth()
  const [settings, setSettings] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [showModal, setShowModal] = useState(false)
  const [editingSetting, setEditingSetting] = useState(null)
  const [formData, setFormData] = useState({
    key: '',
    value: '',
    description: '',
    type: 'string'
  })

  useEffect(() => {
    loadSettings()
  }, [])

  const loadSettings = async () => {
    setLoading(true)
    setError('')
    try {
      const data = await settingsAPI.getAll(token)
      const settingsArray = data?.data?.settings || data?.data || data || []
      setSettings(Array.isArray(settingsArray) ? settingsArray : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editingSetting) {
        await settingsAPI.update(editingSetting.key, formData, token)
      } else {
        await settingsAPI.create(formData, token)
      }
      setShowModal(false)
      setEditingSetting(null)
      setFormData({
        key: '',
        value: '',
        description: '',
        type: 'string'
      })
      setSuccess(editingSetting ? 'Setting updated successfully' : 'Setting created successfully')
      setTimeout(() => setSuccess(''), 3000)
      loadSettings()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleEdit = (setting) => {
    setEditingSetting(setting)
    setFormData({
      key: setting.key,
      value: setting.value,
      description: setting.description || '',
      type: setting.type || 'string'
    })
    setShowModal(true)
  }

  const handleDelete = async (settingKey) => {
    if (window.confirm('Are you sure you want to delete this setting?')) {
      try {
        await settingsAPI.delete(settingKey, token)
        setSuccess('Setting deleted successfully')
        setTimeout(() => setSuccess(''), 3000)
        loadSettings()
      } catch (err) {
        setError(err.message)
      }
    }
  }

  const handleResetDefaults = async () => {
    if (window.confirm('Are you sure you want to reset all settings to default values?')) {
      try {
        await settingsAPI.resetDefaults(token)
        setSuccess('Settings reset to defaults successfully')
        setTimeout(() => setSuccess(''), 3000)
        loadSettings()
      } catch (err) {
        setError(err.message)
      }
    }
  }

  const resetForm = () => {
    setFormData({
      key: '',
      value: '',
      description: '',
      type: 'string'
    })
    setEditingSetting(null)
  }

  const getValueInput = (type, value, onChange) => {
    switch (type) {
      case 'boolean':
        return (
          <select
            value={value}
            onChange={onChange}
            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            <option value="true">True</option>
            <option value="false">False</option>
          </select>
        )
      case 'number':
        return (
          <input
            type="number"
            value={value}
            onChange={onChange}
            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        )
      case 'json':
        return (
          <textarea
            value={value}
            onChange={onChange}
            rows={4}
            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm font-mono text-sm"
          />
        )
      default:
        return (
          <input
            type="text"
            value={value}
            onChange={onChange}
            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        )
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">System Settings</h1>
          <p className="mt-1 text-sm text-gray-500">Manage application configuration and preferences</p>
        </div>
        <div className="flex space-x-3">
          <button
            onClick={handleResetDefaults}
            className="bg-yellow-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-yellow-700"
          >
            Reset Defaults
          </button>
          <button
            onClick={() => {
              resetForm()
              setShowModal(true)
            }}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
          >
            Add Setting
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-sm text-red-700">{error}</div>
        </div>
      )}

      {success && (
        <div className="bg-green-50 border border-green-200 rounded-md p-4">
          <div className="text-sm text-green-700">{success}</div>
        </div>
      )}

      {/* Settings Table */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Key
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Value
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Description
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                      Loading settings...
                    </td>
                  </tr>
                ) : settings.length === 0 ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                      No settings found
                    </td>
                  </tr>
                ) : (
                  (settings || []).map((setting) => (
                    <tr key={setting.key} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{setting.key}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900 max-w-xs truncate">
                          {setting.type === 'json' ? 
                            JSON.stringify(setting.value) : 
                            String(setting.value)
                          }
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          setting.type === 'boolean' ? 'bg-blue-100 text-blue-800' :
                          setting.type === 'number' ? 'bg-green-100 text-green-800' :
                          setting.type === 'json' ? 'bg-purple-100 text-purple-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {setting.type || 'string'}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900 max-w-xs truncate">
                          {setting.description || 'No description'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => handleEdit(setting)}
                          className="text-indigo-600 hover:text-indigo-900 mr-3"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDelete(setting.key)}
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
                {editingSetting ? 'Edit Setting' : 'Add New Setting'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Key</label>
                  <input
                    type="text"
                    required
                    value={formData.key}
                    onChange={(e) => setFormData({ ...formData, key: e.target.value })}
                    disabled={editingSetting}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm disabled:bg-gray-100"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Type</label>
                  <select
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  >
                    <option value="string">String</option>
                    <option value="number">Number</option>
                    <option value="boolean">Boolean</option>
                    <option value="json">JSON</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Value</label>
                  {getValueInput(
                    formData.type,
                    formData.value,
                    (e) => setFormData({ ...formData, value: e.target.value })
                  )}
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
                    {editingSetting ? 'Update' : 'Create'}
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
