import React, { useEffect, useRef, useState } from 'react'
import { Head, Link, router, useForm } from '@inertiajs/react'

const dateLabel = (value) => value ? new Date(`${value}T12:00:00`).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' }) : 'Sem prazo'
const fullDate = (value) => value ? new Date(`${value}T12:00:00`).toLocaleDateString('pt-BR') : ''

function Field({ label, name, form, type = 'text', ...props }) {
  return <label className="field"><span>{label}</span><input type={type} name={name} value={form.data[name] || ''} onChange={e => form.setData(name, e.target.value)} {...props} /></label>
}

function PlanForm({ plan, onSuccess }) {
  const form = useForm({ title: plan?.title || '', purpose: plan?.purpose || '', start_date: plan?.start_date || new Date().toISOString().slice(0, 10), end_date: plan?.end_date || '', status: plan?.status || 'active' })
  const submit = e => {
    e.preventDefault()
    const options = onSuccess ? { onSuccess } : {}
    plan ? form.patch(`/plans/${plan.id}`, options) : form.post('/plans', options)
  }
  return <form className="stack-form" onSubmit={submit}>
    <Field label="Nome do plano" name="title" form={form} placeholder="Ex.: Meu próximo ciclo" required />
    <Field label="Propósito" name="purpose" form={form} placeholder="O que você quer cultivar?" />
    <div className="form-grid"><Field label="Começa em" name="start_date" form={form} type="date" required /><Field label="Termina em" name="end_date" form={form} type="date" required /></div>
    {plan && <label className="field"><span>Status</span><select name="status" value={form.data.status} onChange={e => form.setData('status', e.target.value)}><option value="active">Ativo</option><option value="paused">Em pausa</option><option value="completed">Concluído</option></select></label>}
    {Object.values(form.errors).length > 0 && <p className="form-alert" role="alert">{Object.values(form.errors).flat().join(' ')}</p>}
    <button className="button button-primary" disabled={form.processing}>{form.processing ? 'Salvando…' : plan ? 'Salvar alterações' : 'Criar plano'}</button>
  </form>
}

function goalProgress(goal) {
  const tasks = goal.tasks || []
  if (goal.progress != null) return goal.progress
  if (!tasks.length) return 0
  return Math.round(tasks.filter(task => task.completed).length / tasks.length * 100)
}

function GoalCard({ goal }) {
  const [editing, setEditing] = useState(false)
  const progress = goalProgress(goal)
  const goalForm = useForm({ title: goal.title, description: goal.description || '', due_date: goal.due_date || '' })
  const taskForm = useForm({ title: '' })
  const saveGoal = e => { e.preventDefault(); goalForm.patch(`/goals/${goal.id}`, { onSuccess: () => setEditing(false) }) }
  const addTask = e => { e.preventDefault(); taskForm.post(`/goals/${goal.id}/tasks`, { onSuccess: () => taskForm.reset() }) }
  return <article className="goal-card">
    <div className="goal-heading"><div><span className="eyebrow">Objetivo</span><h3>{goal.title}</h3></div><button className="text-button" onClick={() => setEditing(!editing)} aria-expanded={editing}>{editing ? 'Fechar' : 'Editar'}</button></div>
    {goal.description && !editing && <p className="muted">{goal.description}</p>}
    {goal.due_date && !editing && <p className="due">Até {dateLabel(goal.due_date)}</p>}
    <div className="goal-progress" aria-label={`Progresso do objetivo: ${progress}%`}>
      <div className="goal-progress-heading"><span>Progresso</span><strong>{progress}%</strong></div>
      <progress value={progress} max="100" aria-label={`Progresso: ${progress}%`}>{progress}%</progress>
    </div>
    {editing && <form className="edit-form" onSubmit={saveGoal}><Field label="Título" name="title" form={goalForm} required /><Field label="Descrição" name="description" form={goalForm} /><Field label="Prazo" name="due_date" form={goalForm} type="date" /><button className="button button-small">Salvar objetivo</button></form>}
    <div className="task-list">{goal.tasks.map(task => <TaskRow key={task.id} task={task} />)}</div>
    <form className="add-task" onSubmit={addTask}><input aria-label={`Nova tarefa para ${goal.title}`} placeholder="Adicionar uma tarefa…" value={taskForm.data.title} onChange={e => taskForm.setData('title', e.target.value)} required /><button className="icon-button" aria-label="Adicionar tarefa" disabled={taskForm.processing}>+</button></form>
  </article>
}

function TaskRow({ task }) {
  const form = useForm({ completed: task.completed ? 'false' : 'true' })

  useEffect(() => {
    form.setData('completed', task.completed ? 'false' : 'true')
  }, [task.completed])

  const toggle = e => {
    e.preventDefault()
    form.setData('completed', task.completed ? 'false' : 'true')
    form.patch(`/tasks/${task.id}`)
  }

  return <form className={`task-row ${task.completed ? 'is-done' : ''}`} onSubmit={toggle}><button className="check-button" aria-label={task.completed ? `Reabrir ${task.title}` : `Concluir ${task.title}`} disabled={form.processing}>{task.completed ? '✓' : ''}</button><span>{task.title}</span>{task.completed && <small>+25 XP</small>}</form>
}

function CheckIn({ plan }) {
  const form = useForm({ reflection: '' })
  const submit = e => { e.preventDefault(); form.post(`/plans/${plan.id}/check_ins`, { onSuccess: () => form.reset() }) }
  return <section className="panel checkin"><div><span className="eyebrow">Pausa para perceber</span><h2>Como foi caminhar hoje?</h2><p className="muted">Uma frase já é suficiente. O que você aprendeu sobre o caminho?</p></div><form onSubmit={submit}><textarea name="reflection" value={form.data.reflection} onChange={e => form.setData('reflection', e.target.value)} placeholder="Escreva uma breve reflexão…" maxLength="1000" required /><div className="form-actions"><span className="muted">{form.data.reflection.length}/1000</span><button className="button button-primary" disabled={form.processing}>Salvar check-in</button></div></form>{plan.check_ins?.length > 0 && <div className="past-checkins"><span className="eyebrow">Últimas reflexões</span>{plan.check_ins.map(item => <p key={item.id}><strong>{fullDate(item.checked_in_on)}</strong> {item.reflection}</p>)}</div>}</section>
}

export default function Dashboard({ user, plans, active_plan: plan, recent_xp: recentXp, flash = {} }) {
  const [showNewPlan, setShowNewPlan] = useState(false)
  const [showEditPlan, setShowEditPlan] = useState(false)
  const newPlanCloseButton = useRef(null)
  const goalForm = useForm({ title: '', description: '', due_date: '' })
  const exportForm = useForm({})
  const pendingExports = plan?.exports?.some(item => ['queued', 'processing'].includes(item.status))
  const xpToNextLevel = 100 - (user.xp % 100)

  useEffect(() => {
    if (!showNewPlan) return
    newPlanCloseButton.current?.focus()
    const closeOnEscape = event => event.key === 'Escape' && setShowNewPlan(false)
    document.addEventListener('keydown', closeOnEscape)
    return () => document.removeEventListener('keydown', closeOnEscape)
  }, [showNewPlan])

  useEffect(() => {
    if (!pendingExports) return
    const interval = window.setInterval(() => router.reload({ only: ['active_plan'], preserveScroll: true }), 2000)
    return () => window.clearInterval(interval)
  }, [pendingExports])

  const addGoal = e => { e.preventDefault(); goalForm.post(`/plans/${plan.id}/goals`, { onSuccess: () => goalForm.reset() }) }
  const createExport = e => { e.preventDefault(); exportForm.post(`/plans/${plan.id}/exports`) }
  const totalTasks = plan?.task_count || 0
  return <><Head title="Meu ciclo · PDI" /><div className="app-shell"><aside className="sidebar"><div className="brand"><span className="brand-mark">p</span><span>PDI</span></div><div className="side-label">Meus planos</div><nav>{plans.map(item => <Link key={item.id} href={`/?plan_id=${item.id}`} className={item.id === plan?.id ? 'plan-link active' : 'plan-link'}><span>{item.title}</span><small>{item.progress}%</small></Link>)}</nav><button className="button button-secondary button-full" onClick={() => setShowNewPlan(true)}>+ Novo plano</button><div className="sidebar-bottom"><div className="level-mini"><strong>Nível {user.level}</strong><span>{user.xp} XP</span></div><small className="level-next">Faltam {xpToNextLevel} XP para o nível {user.level + 1}</small><Link href="/session" method="delete" as="button" className="logout">Sair</Link></div></aside><main className="main-content"><header className="topbar"><div><p className="eyebrow">Seu espaço de crescimento</p><h1>{plan ? `Olá, ${user.email.split('@')[0]}.` : 'Vamos começar?'}</h1></div><div className="xp-badge"><span className="spark">✦</span><div><strong>{user.xp} XP</strong><small>Nível {user.level} · faltam {xpToNextLevel} XP</small></div></div></header>{flash.notice && <div className="flash notice" role="status">{flash.notice}</div>}{flash.alert && <div className="flash alert" role="alert">{flash.alert}</div>}{!plan ? <section className="empty-state panel"><span className="empty-icon">✦</span><h2>Um plano de cada vez.</h2><p className="muted">Crie um ciclo com intenção e escolha o primeiro passo possível.</p><button className="button button-primary" onClick={() => setShowNewPlan(true)}>Criar meu primeiro plano</button></section> : <><section className="plan-hero panel"><div><div className="hero-title"><h2>{plan.title}</h2><button className="text-button" onClick={() => setShowEditPlan(!showEditPlan)}>{showEditPlan ? 'Fechar edição' : 'Editar plano'}</button></div><p className="purpose">{plan.purpose || 'Um ciclo para avançar com presença.'}</p><p className="date-range">{fullDate(plan.start_date)} — {fullDate(plan.end_date)} <span className="status-pill">{plan.status === 'active' ? 'Ativo' : plan.status === 'paused' ? 'Em pausa' : 'Concluído'}</span></p></div><div className="progress-ring" style={{ '--progress': `${plan.progress * 3.6}deg` }}><strong>{plan.progress}%</strong><small>feito</small></div></section>{showEditPlan && <section className="panel inline-editor"><h2>Editar plano</h2><PlanForm plan={plan} /></section>}<div className="content-grid"><section><div className="section-heading"><div><span className="eyebrow">Plano de ação</span><h2>Objetivos e tarefas</h2></div><span className="count-label">{plan.completed_tasks}/{totalTasks} tarefas</span></div><div className="goal-stack">{plan.goals?.map(goal => <GoalCard key={goal.id} goal={goal} />)}</div><form className="panel add-goal" onSubmit={addGoal}><span className="eyebrow">Novo objetivo</span><Field label="Título do objetivo" name="title" form={goalForm} placeholder="Ex.: Cuidar da minha energia" required /><div className="form-grid"><Field label="Descrição (opcional)" name="description" form={goalForm} placeholder="Como saberemos que avançou?" /><Field label="Prazo" name="due_date" form={goalForm} type="date" /></div><button className="button button-secondary" disabled={goalForm.processing}>Adicionar objetivo</button></form></section><aside className="right-column"><CheckIn plan={plan} /><section className="panel xp-panel"><div className="section-heading"><div><span className="eyebrow">Progresso acumulado</span><h2>Histórico de XP</h2></div><span className="xp-rule">25 XP / tarefa</span></div>{recentXp.length === 0 ? <p className="muted">Conclua uma tarefa para registrar seu primeiro ponto de progresso.</p> : <div className="xp-list">{recentXp.map(item => <div className="xp-item" key={item.id}><span className={item.points > 0 ? 'xp-dot' : 'xp-dot reversal'}>{item.points > 0 ? '+' : '−'}</span><div><strong>{item.task_title}</strong><small>{item.kind === 'completion' ? 'Tarefa concluída' : 'Tarefa reaberta'} · {dateLabel(item.created_at.slice(0, 10))}</small></div><b>{item.points > 0 ? '+' : ''}{item.points} XP</b></div>)}</div>}</section><section className="panel export-panel"><div><span className="eyebrow">Leve com você</span><h2>Relatório completo</h2><p className="muted">Uma planilha com visão geral, objetivos, tarefas, XP e check-ins.</p></div><form onSubmit={createExport}><button className="button button-secondary" disabled={exportForm.processing}>{exportForm.processing ? 'Preparando…' : 'Gerar XLSX'}</button></form><div className="export-list">{plan.exports?.map(item => <div className="export-item" key={item.id}>{item.status === 'ready' && <a className="download-link" href={item.download_url}>Baixar relatório #{item.id}</a>}{['queued', 'processing'].includes(item.status) && <p className="export-pending" role="status">Relatório #{item.id}: {item.status === 'queued' ? 'na fila' : 'preparando'}…</p>}{item.status === 'failed' && <p className="export-failed" role="alert">Não foi possível gerar o relatório #{item.id}. Tente novamente.</p>}</div>)}</div></section></aside></div></>}</main></div>{showNewPlan && <div className="modal-backdrop" role="presentation" onClick={e => e.target === e.currentTarget && setShowNewPlan(false)}><section className="modal" role="dialog" aria-modal="true" aria-labelledby="new-plan-title" aria-describedby="new-plan-description"><button ref={newPlanCloseButton} className="modal-close" onClick={() => setShowNewPlan(false)} aria-label="Fechar">×</button><span className="eyebrow">Novo ciclo</span><h2 id="new-plan-title">O que você quer cultivar?</h2><p id="new-plan-description" className="muted">Dê um nome ao plano. Você pode ajustar tudo depois.</p><PlanForm onSuccess={() => setShowNewPlan(false)} /></section></div>}</>
}
