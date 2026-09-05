import React, { useCallback, useState } from 'react'
import { Head } from '@inertiajs/react'
import DashboardHeader from '../components/dashboard/DashboardHeader'
import DashboardSidebar from '../components/dashboard/DashboardSidebar'
import NewPlanModal from '../components/dashboard/NewPlanModal'
import PlanWorkspace from '../components/dashboard/PlanWorkspace'

export default function Dashboard({ user, plans, active_plan: plan, recent_xp: recentXp, flash = {} }) {
  const [showNewPlan, setShowNewPlan] = useState(false)
  const closeNewPlan = useCallback(() => setShowNewPlan(false), [])
  const xpToNextLevel = 100 - (user.xp % 100)

  return (
    <>
      <Head title="Meu ciclo · PDI" />
      <div className="app-shell">
        <DashboardSidebar plans={plans} plan={plan} user={user} xpToNextLevel={xpToNextLevel} onNewPlan={() => setShowNewPlan(true)} />
        <main className="main-content">
          <DashboardHeader user={user} plan={plan} xpToNextLevel={xpToNextLevel} />
          {flash.notice && <div className="flash notice" role="status">{flash.notice}</div>}
          {flash.alert && <div className="flash alert" role="alert">{flash.alert}</div>}
          {!plan ? (
            <section className="empty-state panel">
              <span className="empty-icon">✦</span>
              <h2>Um plano de cada vez.</h2>
              <p className="muted">Crie um ciclo com intenção e escolha o primeiro passo possível.</p>
              <button className="button button-primary" onClick={() => setShowNewPlan(true)}>Criar meu primeiro plano</button>
            </section>
          ) : (
            <PlanWorkspace plan={plan} recentXp={recentXp} />
          )}
        </main>
      </div>
      {showNewPlan && <NewPlanModal onClose={closeNewPlan} />}
    </>
  )
}
