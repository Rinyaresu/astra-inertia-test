import React, { useState } from 'react'
import { useForm } from '@inertiajs/react'
import Field from './Field'
import TaskRow from './TaskRow'
import { dateLabel } from './date'

const goalProgress = goal => {
  const tasks = goal.tasks || []
  if (goal.progress != null) return goal.progress
  if (!tasks.length) return 0
  return Math.round(tasks.filter(task => task.completed).length / tasks.length * 100)
}

export default function GoalCard({ goal }) {
  const [editing, setEditing] = useState(false)
  const progress = goalProgress(goal)
  const goalForm = useForm({ title: goal.title, description: goal.description || '', due_date: goal.due_date || '' })
  const taskForm = useForm({ title: '' })
  const saveGoal = e => { e.preventDefault(); goalForm.patch(`/goals/${goal.id}`, { onSuccess: () => setEditing(false) }) }
  const addTask = e => { e.preventDefault(); taskForm.post(`/goals/${goal.id}/tasks`, { onSuccess: () => taskForm.reset() }) }

  return (
    <article className="goal-card">
      <div className="goal-heading">
        <div>
          <span className="eyebrow">Objetivo</span>
          <h3>{goal.title}</h3>
        </div>
        <button className="text-button" onClick={() => setEditing(!editing)} aria-expanded={editing}>
          {editing ? 'Fechar' : 'Editar'}
        </button>
      </div>
      {goal.description && !editing && <p className="muted">{goal.description}</p>}
      {goal.due_date && !editing && <p className="due">Até {dateLabel(goal.due_date)}</p>}
      <div className="goal-progress" aria-label={`Progresso do objetivo: ${progress}%`}>
        <div className="goal-progress-heading"><span>Progresso</span><strong>{progress}%</strong></div>
        <progress value={progress} max="100" aria-label={`Progresso: ${progress}%`}>{progress}%</progress>
      </div>
      {editing && (
        <form className="edit-form" onSubmit={saveGoal}>
          <Field label="Título" name="title" form={goalForm} required />
          <Field label="Descrição" name="description" form={goalForm} />
          <Field label="Prazo" name="due_date" form={goalForm} type="date" />
          <button className="button button-small">Salvar objetivo</button>
        </form>
      )}
      <div className="task-list">{goal.tasks.map(task => <TaskRow key={task.id} task={task} />)}</div>
      <form className="add-task" onSubmit={addTask}>
        <input aria-label={`Nova tarefa para ${goal.title}`} placeholder="Adicionar uma tarefa…" value={taskForm.data.title} onChange={e => taskForm.setData('title', e.target.value)} required />
        <button className="icon-button" aria-label="Adicionar tarefa" disabled={taskForm.processing}>+</button>
      </form>
    </article>
  )
}
