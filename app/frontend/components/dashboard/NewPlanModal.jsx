import React, { useEffect, useRef } from 'react'
import PlanForm from './PlanForm'

export default function NewPlanModal({ onClose }) {
  const closeButton = useRef(null)

  useEffect(() => {
    closeButton.current?.focus()
    const closeOnEscape = event => event.key === 'Escape' && onClose()
    document.addEventListener('keydown', closeOnEscape)
    return () => document.removeEventListener('keydown', closeOnEscape)
  }, [onClose])

  return (
    <div className="modal-backdrop" role="presentation" onClick={e => e.target === e.currentTarget && onClose()}>
      <section className="modal" role="dialog" aria-modal="true" aria-labelledby="new-plan-title" aria-describedby="new-plan-description">
        <button ref={closeButton} className="modal-close" onClick={onClose} aria-label="Fechar">×</button>
        <span className="eyebrow">Novo ciclo</span>
        <h2 id="new-plan-title">O que você quer cultivar?</h2>
        <p id="new-plan-description" className="muted">Dê um nome ao plano. Você pode ajustar tudo depois.</p>
        <PlanForm onSuccess={onClose} />
      </section>
    </div>
  )
}
