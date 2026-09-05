import React, { useState } from 'react'
import CheckIn from './CheckIn'
import GoalsSection from './GoalsSection'
import PlanExport from './PlanExport'
import PlanForm from './PlanForm'
import PlanHero from './PlanHero'
import XpHistory from './XpHistory'

export default function PlanWorkspace({ plan, recentXp }) {
  const [showEditPlan, setShowEditPlan] = useState(false)

  return (
    <>
      <PlanHero plan={plan} showEditPlan={showEditPlan} onToggleEdit={() => setShowEditPlan(!showEditPlan)} />
      {showEditPlan && (
        <section className="panel inline-editor">
          <h2>Editar plano</h2>
          <PlanForm plan={plan} />
        </section>
      )}
      <div className="content-grid">
        <GoalsSection plan={plan} />
        <aside className="right-column">
          <CheckIn plan={plan} />
          <XpHistory recentXp={recentXp} />
          <PlanExport plan={plan} />
        </aside>
      </div>
    </>
  )
}
