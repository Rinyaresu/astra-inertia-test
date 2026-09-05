export const dateLabel = value => value ? new Date(`${value}T12:00:00`).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' }) : 'Sem prazo'
export const fullDate = value => value ? new Date(`${value}T12:00:00`).toLocaleDateString('pt-BR') : ''
