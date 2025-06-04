import { useState } from 'react'
import axios from 'axios'

export default function App() {
  const [message, setMessage] = useState('')
  const [status, setStatus] = useState(null)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setStatus(null)
    try {
      await axios.post('/submit-feedback', { message })
      setStatus('success')
      setMessage('')
    } catch (err) {
      setStatus('error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
      <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow max-w-md w-full space-y-4">
        <h1 className="text-2xl font-semibold text-center">Send Feedback</h1>
        <textarea
          className="w-full p-3 border rounded focus:outline-none focus:ring"
          rows="4"
          placeholder="Your feedback..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          required
        />
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 transition-colors disabled:opacity-50"
        >
          {loading ? 'Sending...' : 'Submit'}
        </button>
        {status === 'success' && <p className="text-green-600 text-center">Feedback sent!</p>}
        {status === 'error' && <p className="text-red-600 text-center">Error sending feedback.</p>}
      </form>
    </div>
  )
}
