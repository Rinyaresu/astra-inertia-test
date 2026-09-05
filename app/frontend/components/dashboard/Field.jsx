import React from 'react'

export default function Field({ label, name, form, type = 'text', ...props }) {
  return (
    <label className="field">
      <span>{label}</span>
      <input
        type={type}
        name={name}
        value={form.data[name] || ''}
        onChange={e => form.setData(name, e.target.value)}
        {...props}
      />
    </label>
  )
}
