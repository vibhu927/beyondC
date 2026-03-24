'use client'

import {
  ResponsiveContainer,
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts'

const PIE_COLORS = ['#84cc16', '#0ea5e9', '#f97316', '#ef4444', '#a855f7']

export function AdminLineChart({
  data,
  lines,
}: {
  data: Record<string, any>[]
  lines: Array<{ key: string; color: string; name: string }>
}) {
  return (
    <div className="h-72 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="label" />
          <YAxis />
          <Tooltip
            contentStyle={{ backgroundColor: '#18181b', border: '1px solid #3f3f46', borderRadius: '10px' }}
            labelStyle={{ color: '#d4d4d8' }}
            itemStyle={{ color: '#fafafa' }}
          />
          {lines.map((line) => (
            <Line key={line.key} type="monotone" dataKey={line.key} stroke={line.color} strokeWidth={2} name={line.name} />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}

export function AdminBarChart({
  data,
  keyName,
  color,
}: {
  data: Record<string, any>[]
  keyName: string
  color?: string
}) {
  return (
    <div className="h-72 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="label" />
          <YAxis />
          <Tooltip
            contentStyle={{ backgroundColor: '#18181b', border: '1px solid #3f3f46', borderRadius: '10px' }}
            labelStyle={{ color: '#d4d4d8' }}
            itemStyle={{ color: '#fafafa' }}
          />
          <Bar dataKey={keyName} fill={color ?? '#84cc16'} radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

export function AdminPieChart({
  data,
  dataKey,
}: {
  data: Array<{ name: string; [key: string]: string | number }>
  dataKey: string
}) {
  return (
    <div className="h-72 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie data={data} dataKey={dataKey} nameKey="name" outerRadius={100} label>
            {data.map((_, i) => (
              <Cell key={`cell-${i}`} fill={PIE_COLORS[i % PIE_COLORS.length]} />
            ))}
          </Pie>
          <Tooltip
            contentStyle={{ backgroundColor: '#18181b', border: '1px solid #3f3f46', borderRadius: '10px' }}
            labelStyle={{ color: '#d4d4d8' }}
            itemStyle={{ color: '#fafafa' }}
          />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </div>
  )
}
