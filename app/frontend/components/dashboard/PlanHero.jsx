import React from 'react'
import { fullDate } from './date'

export default function PlanHero({ plan, showEditPlan, onToggleEdit }) {
  return (
    <section className="plan-hero panel">
      <div>
        <div className="hero-title">
          <h2>{plan.title}</h2>
          <button className="text-button" onClick={onToggleEdit}>{showEditPlan ? 'Fechar edição' : 'Editar plano'}</button>
        </div>
        <p className="purpose">{plan.purpose || 'Um ciclo para avançar com presença.'}</p>
        <p className="date-range">
          {fullDate(plan.start_date)} — {fullDate(plan.end_date)}
          <span className="status-pill">{plan.status === 'active' ? 'Ativo' : plan.status === 'paused' ? 'Em pausa' : 'Concluído'}</span>
        </p>
      </div>
      <div className="progress-ring" style={{ '--progress': `${plan.progress * 3.6}deg` }}>
        <strong>{plan.progress}%</strong>
        <small>feito</small>
      </div>
    </section>
  )
}
