import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminStaffPage() {
  const service = createServiceClient()

  const [staff, roles, permissions] = await Promise.all([
    service
      .from('admin_staff')
      .select('id,role_id,designation,is_active,created_at,profiles!admin_staff_id_fkey(full_name,email),admin_roles(name,designation)')
      .order('created_at', { ascending: false })
      .limit(20),
    service.from('admin_roles').select('*').order('name', { ascending: true }),
    service.from('admin_permissions').select('*').order('page', { ascending: true }),
  ])

  return (
    <PermissionGate page="staff" action="can_view">
      <Card>
        <CardHeader><CardTitle>Staff Management</CardTitle></CardHeader>
        <CardContent>
          <Tabs defaultValue="members">
            <TabsList>
              <TabsTrigger value="members">Staff Members</TabsTrigger>
              <TabsTrigger value="roles">Roles & Permissions</TabsTrigger>
            </TabsList>

            <TabsContent value="members">
              <div className="mb-4 rounded-md border border-zinc-200 p-4 dark:border-zinc-700 dark:bg-zinc-900/50">
                <h3 className="mb-2 font-semibold">Add Staff Member</h3>
                <form action="/api/admin/staff" method="post" className="grid grid-cols-1 gap-2 md:grid-cols-4">
                  <Input name="email" placeholder="User email" required />
                  <Input name="role_id" placeholder="Role ID" required />
                  <Input name="designation" placeholder="Designation override (optional)" />
                  <Button type="submit">Add Staff Member</Button>
                </form>
              </div>

              <div className="overflow-x-auto">
                <Table>
                  <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Email</TableHead><TableHead>Designation</TableHead><TableHead>Role</TableHead><TableHead>Status</TableHead><TableHead>Added</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
                  <TableBody>
                    {(staff.data ?? []).map((row: any) => (
                      <TableRow key={row.id}>
                        <TableCell>{row.profiles?.full_name || '-'}</TableCell>
                        <TableCell>{row.profiles?.email || '-'}</TableCell>
                        <TableCell>{row.designation || row.admin_roles?.designation || '-'}</TableCell>
                        <TableCell>{row.admin_roles?.name || '-'}</TableCell>
                        <TableCell>{row.is_active ? 'active' : 'inactive'}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleDateString()}</TableCell>
                        <TableCell>
                          <form action={`/api/admin/staff/${row.id}`} method="post" className="flex gap-2">
                            <input type="hidden" name="_method" value="PUT" />
                            <input type="hidden" name="is_active" value={row.is_active ? 'false' : 'true'} />
                            <Button size="sm" variant="outline" type="submit">{row.is_active ? 'Deactivate' : 'Activate'}</Button>
                          </form>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </TabsContent>

            <TabsContent value="roles">
              <div className="mb-4 rounded-md border border-zinc-200 p-4 dark:border-zinc-700 dark:bg-zinc-900/50">
                <h3 className="mb-2 font-semibold">Add Role</h3>
                <form action="/api/admin/staff" method="post" className="grid grid-cols-1 gap-2 md:grid-cols-4">
                  <input type="hidden" name="action" value="create_role" />
                  <Input name="name" placeholder="Role name" required />
                  <Input name="designation" placeholder="Designation" required />
                  <Textarea name="description" placeholder="Description" className="min-h-[40px]" />
                  <Button type="submit">Create Role</Button>
                </form>
              </div>

              <div className="space-y-4">
                {(roles.data ?? []).map((role) => {
                  const rolePerms = (permissions.data ?? []).filter((perm) => perm.role_id === role.id)
                  return (
                    <Card key={role.id}>
                      <CardHeader><CardTitle>{role.designation} ({role.name})</CardTitle></CardHeader>
                      <CardContent className="overflow-x-auto">
                        <Table>
                          <TableHeader><TableRow><TableHead>Page</TableHead><TableHead>View</TableHead><TableHead>Edit</TableHead><TableHead>Delete</TableHead></TableRow></TableHeader>
                          <TableBody>
                            {rolePerms.map((perm) => (
                              <TableRow key={perm.id}>
                                <TableCell>{perm.page}</TableCell>
                                <TableCell>
                                  <form action={`/api/admin/staff/${role.id}`} method="post">
                                    <input type="hidden" name="_method" value="PUT" />
                                    <input type="hidden" name="action" value="toggle_permission" />
                                    <input type="hidden" name="permission_id" value={perm.id} />
                                    <input type="hidden" name="field" value="can_view" />
                                    <Button size="sm" variant="outline" type="submit">{perm.can_view ? 'Yes' : 'No'}</Button>
                                  </form>
                                </TableCell>
                                <TableCell>
                                  <form action={`/api/admin/staff/${role.id}`} method="post">
                                    <input type="hidden" name="_method" value="PUT" />
                                    <input type="hidden" name="action" value="toggle_permission" />
                                    <input type="hidden" name="permission_id" value={perm.id} />
                                    <input type="hidden" name="field" value="can_edit" />
                                    <Button size="sm" variant="outline" type="submit">{perm.can_edit ? 'Yes' : 'No'}</Button>
                                  </form>
                                </TableCell>
                                <TableCell>
                                  <form action={`/api/admin/staff/${role.id}`} method="post">
                                    <input type="hidden" name="_method" value="PUT" />
                                    <input type="hidden" name="action" value="toggle_permission" />
                                    <input type="hidden" name="permission_id" value={perm.id} />
                                    <input type="hidden" name="field" value="can_delete" />
                                    <Button size="sm" variant="outline" type="submit">{perm.can_delete ? 'Yes' : 'No'}</Button>
                                  </form>
                                </TableCell>
                              </TableRow>
                            ))}
                          </TableBody>
                        </Table>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
