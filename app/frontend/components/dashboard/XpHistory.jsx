import React from 'react'
import { dateLabel } from './date'

export default function XpHistory({ recentXp }) {
  return (
    <section className="panel xp-panel">
      <div className="section-heading">
        <div>
          <span className="eyebrow">Progresso acumulado</span>
          <h2>Histórico de XP</h2>
        </div>
        <span className="xp-rule">25 XP / tarefa</span>
      </div>
      {recentXp.length === 0 ? (
        <p className="muted">Conclua uma tarefa para registrar seu primeiro ponto de progresso.</p>
      ) : (
        <div className="xp-list">
          {recentXp.map(item => (
            <div className="xp-item" key={item.id}>
              <span className={item.points > 0 ? 'xp-dot' : 'xp-dot reversal'}>{item.points > 0 ? '+' : '−'}</span>
              <div>
                <strong>{item.task_title}</strong>
                <small>{item.kind === 'completion' ? 'Tarefa concluída' : 'Tarefa reaberta'} · {dateLabel(item.created_at.slice(0, 10))}</small>
              </div>
              <b>{item.points > 0 ? '+' : ''}{item.points} XP</b>
            </div>
          ))}
        </div>
      )}
    </section>
  )
}
