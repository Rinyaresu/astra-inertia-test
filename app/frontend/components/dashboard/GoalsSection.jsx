import React from 'react'
import { useForm } from '@inertiajs/react'
import Field from './Field'
import GoalCard from './GoalCard'

export default function GoalsSection({ plan }) {
  const goalForm = useForm({ title: '', description: '', due_date: '' })
  const totalTasks = plan?.task_count || 0
  const addGoal = e => { e.preventDefault(); goalForm.post(`/plans/${plan.id}/goals`, { onSuccess: () => goalForm.reset() }) }
  return (
    <section>
      <div className="section-heading">
        <div>
          <span className="eyebrow">Plano de ação</span>
          <h2>Objetivos e tarefas</h2>
        </div>
        <span className="count-label">{plan.completed_tasks}/{totalTasks} tarefas</span>
      </div>
      <div className="goal-stack">{plan.goals?.map(goal => <GoalCard key={goal.id} goal={goal} />)}</div>
      <form className="panel add-goal" onSubmit={addGoal}>
        <span className="eyebrow">Novo objetivo</span>
        <Field label="Título do objetivo" name="title" form={goalForm} placeholder="Ex.: Cuidar da minha energia" required />
        <div className="form-grid">
          <Field label="Descrição (opcional)" name="description" form={goalForm} placeholder="Como saberemos que avançou?" />
          <Field label="Prazo" name="due_date" form={goalForm} type="date" />
        </div>
        <button className="button button-secondary" disabled={goalForm.processing}>Adicionar objetivo</button>
      </form>
    </section>
  )
}
