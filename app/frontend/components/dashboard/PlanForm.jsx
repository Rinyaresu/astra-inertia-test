import React from 'react'
import { useForm } from '@inertiajs/react'
import Field from './Field'

export default function PlanForm({ plan, onSuccess }) {
  const form = useForm({
    title: plan?.title || '',
    purpose: plan?.purpose || '',
    start_date: plan?.start_date || new Date().toISOString().slice(0, 10),
    end_date: plan?.end_date || '',
    status: plan?.status || 'active',
  })

  const submit = e => {
    e.preventDefault()
    const options = onSuccess ? { onSuccess } : {}
    plan ? form.patch(`/plans/${plan.id}`, options) : form.post('/plans', options)
  }

  return (
    <form className="stack-form" onSubmit={submit}>
      <Field label="Nome do plano" name="title" form={form} placeholder="Ex.: Meu próximo ciclo" required />
      <Field label="Propósito" name="purpose" form={form} placeholder="O que você quer cultivar?" />
      <div className="form-grid">
        <Field label="Começa em" name="start_date" form={form} type="date" required />
        <Field label="Termina em" name="end_date" form={form} type="date" required />
      </div>
      {plan && (
        <label className="field">
          <span>Status</span>
          <select name="status" value={form.data.status} onChange={e => form.setData('status', e.target.value)}>
            <option value="active">Ativo</option>
            <option value="paused">Em pausa</option>
            <option value="completed">Concluído</option>
          </select>
        </label>
      )}
      {Object.values(form.errors).length > 0 && <p className="form-alert" role="alert">{Object.values(form.errors).flat().join(' ')}</p>}
      <button className="button button-primary" disabled={form.processing}>
        {form.processing ? 'Salvando…' : plan ? 'Salvar alterações' : 'Criar plano'}
      </button>
    </form>
  )
}
