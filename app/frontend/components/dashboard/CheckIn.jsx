import React from 'react'
import { useForm } from '@inertiajs/react'
import { fullDate } from './date'

export default function CheckIn({ plan }) {
  const form = useForm({ reflection: '' })
  const submit = e => { e.preventDefault(); form.post(`/plans/${plan.id}/check_ins`, { onSuccess: () => form.reset() }) }

  return (
    <section className="panel checkin">
      <div>
        <span className="eyebrow">Pausa para perceber</span>
        <h2>Como foi caminhar hoje?</h2>
        <p className="muted">Uma frase já é suficiente. O que você aprendeu sobre o caminho?</p>
      </div>
      <form onSubmit={submit}>
        <textarea name="reflection" value={form.data.reflection} onChange={e => form.setData('reflection', e.target.value)} placeholder="Escreva uma breve reflexão…" maxLength="1000" required />
        <div className="form-actions">
          <span className="muted">{form.data.reflection.length}/1000</span>
          <button className="button button-primary" disabled={form.processing}>Salvar check-in</button>
        </div>
      </form>
      {plan.check_ins?.length > 0 && (
        <div className="past-checkins">
          <span className="eyebrow">Últimas reflexões</span>
          {plan.check_ins.map(item => <p key={item.id}><strong>{fullDate(item.checked_in_on)}</strong> {item.reflection}</p>)}
        </div>
      )}
    </section>
  )
}
