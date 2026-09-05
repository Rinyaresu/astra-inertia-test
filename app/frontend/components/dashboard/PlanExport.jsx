import React, { useEffect } from 'react'
import { router, useForm } from '@inertiajs/react'

export default function PlanExport({ plan }) {
  const form = useForm({})
  const pendingExports = plan?.exports?.some(item => ['queued', 'processing'].includes(item.status))

  useEffect(() => {
    if (!pendingExports) return
    const interval = window.setInterval(() => router.reload({ only: ['active_plan'], preserveScroll: true }), 2000)
    return () => window.clearInterval(interval)
  }, [pendingExports])

  const createExport = e => { e.preventDefault(); form.post(`/plans/${plan.id}/exports`) }
  return (
    <section className="panel export-panel">
      <div>
        <span className="eyebrow">Leve com você</span>
        <h2>Relatório completo</h2>
        <p className="muted">Uma planilha com visão geral, objetivos, tarefas, XP e check-ins.</p>
      </div>
      <form onSubmit={createExport}>
        <button className="button button-secondary" disabled={form.processing}>
          {form.processing ? 'Preparando…' : 'Gerar XLSX'}
        </button>
      </form>
      <div className="export-list">
        {plan.exports?.map(item => (
          <div className="export-item" key={item.id}>
            {item.status === 'ready' && <a className="download-link" href={item.download_url}>Baixar relatório #{item.id}</a>}
            {['queued', 'processing'].includes(item.status) && <p className="export-pending" role="status">Relatório #{item.id}: {item.status === 'queued' ? 'na fila' : 'preparando'}…</p>}
            {item.status === 'failed' && <p className="export-failed" role="alert">Não foi possível gerar o relatório #{item.id}. Tente novamente.</p>}
          </div>
        ))}
      </div>
    </section>
  )
}
