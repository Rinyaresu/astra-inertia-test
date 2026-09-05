import React, { useEffect } from 'react'
import { useForm } from '@inertiajs/react'

export default function TaskRow({ task }) {
  const form = useForm({ completed: task.completed ? 'false' : 'true' })

  useEffect(() => {
    form.setData('completed', task.completed ? 'false' : 'true')
  }, [task.completed])

  const toggle = e => {
    e.preventDefault()
    form.setData('completed', task.completed ? 'false' : 'true')
    form.patch(`/tasks/${task.id}`)
  }

  return (
    <form className={`task-row ${task.completed ? 'is-done' : ''}`} onSubmit={toggle}>
      <button className="check-button" aria-label={task.completed ? `Reabrir ${task.title}` : `Concluir ${task.title}`} disabled={form.processing}>
        {task.completed ? '✓' : ''}
      </button>
      <span>{task.title}</span>
      {task.completed && <small>+25 XP</small>}
    </form>
  )
}
