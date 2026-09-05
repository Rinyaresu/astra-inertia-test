import React from 'react'

export default function DashboardHeader({ user, plan, xpToNextLevel }) {
  return (
    <header className="topbar">
      <div>
        <p className="eyebrow">Seu espaço de crescimento</p>
        <h1>{plan ? `Olá, ${user.email.split('@')[0]}.` : 'Vamos começar?'}</h1>
      </div>
      <div className="xp-badge">
        <span className="spark">✦</span>
        <div>
          <strong>{user.xp} XP</strong>
          <small>Nível {user.level} · faltam {xpToNextLevel} XP</small>
        </div>
      </div>
    </header>
  )
}
