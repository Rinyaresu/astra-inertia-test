import React from 'react'
import { Link } from '@inertiajs/react'

export default function DashboardSidebar({ plans, plan, user, xpToNextLevel, onNewPlan }) {
  return (
    <aside className="sidebar">
      <div className="brand"><span className="brand-mark">p</span><span>PDI</span></div>
      <div className="side-label">Meus planos</div>
      <nav>
        {plans.map(item => (
          <Link key={item.id} href={`/?plan_id=${item.id}`} className={item.id === plan?.id ? 'plan-link active' : 'plan-link'}>
            <span>{item.title}</span>
            <small>{item.progress}%</small>
          </Link>
        ))}
      </nav>
      <button className="button button-secondary button-full" onClick={onNewPlan}>+ Novo plano</button>
      <div className="sidebar-bottom">
        <div className="level-mini"><strong>Nível {user.level}</strong><span>{user.xp} XP</span></div>
        <small className="level-next">Faltam {xpToNextLevel} XP para o nível {user.level + 1}</small>
        <Link href="/session" method="delete" as="button" className="logout">Sair</Link>
      </div>
    </aside>
  )
}
