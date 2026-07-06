import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { supabase } from '../utils/supabase';
import { hashPassword } from '../utils/auth';
import type { AppUser } from '../types';

interface AuthContextType {
  user: AppUser | null;
  login: (username: string, password: string) => Promise<boolean>;
  logout: () => void;
  changeCredentials: (currentPassword: string, newUsername: string, newPassword: string) => Promise<{ ok: boolean; error?: string }>;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AppUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem('gohar_user');
    if (stored) {
      try {
        setUser(JSON.parse(stored));
      } catch {
        localStorage.removeItem('gohar_user');
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (username: string, password: string): Promise<boolean> => {
    const { data: row } = await supabase
      .from('users')
      .select('*')
      .ilike('username', username.trim())
      .eq('is_active', true)
      .maybeSingle();

    if (!row) return false;

    const hash = await hashPassword(row.username, password);
    if (hash !== row.password_hash) return false;

    const appUser: AppUser = {
      id: row.id,
      username: row.username,
      role: row.role,
      full_name: row.full_name,
      phone: row.phone,
      is_active: row.is_active,
    };

    setUser(appUser);
    localStorage.setItem('gohar_user', JSON.stringify(appUser));
    return true;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('gohar_user');
  };

  const changeCredentials = async (
    currentPassword: string,
    newUsername: string,
    newPassword: string
  ): Promise<{ ok: boolean; error?: string }> => {
    if (!user) return { ok: false, error: 'Not logged in' };

    const { data: row } = await supabase.from('users').select('*').eq('id', user.id).maybeSingle();
    if (!row) return { ok: false, error: 'Account not found' };

    const currentHash = await hashPassword(row.username, currentPassword);
    if (currentHash !== row.password_hash) return { ok: false, error: 'Current password is incorrect' };

    const trimmedUsername = newUsername.trim() || row.username;
    if (trimmedUsername.toLowerCase() !== row.username.toLowerCase()) {
      const { data: existing } = await supabase
        .from('users')
        .select('id')
        .ilike('username', trimmedUsername)
        .neq('id', user.id)
        .maybeSingle();
      if (existing) return { ok: false, error: 'That username is already taken' };
    }

    const newHash = newPassword ? await hashPassword(trimmedUsername, newPassword) : row.password_hash;

    const { error } = await supabase
      .from('users')
      .update({ username: trimmedUsername.toLowerCase(), password_hash: newHash })
      .eq('id', user.id);

    if (error) return { ok: false, error: 'Could not save changes' };

    const updatedUser: AppUser = { ...user, username: trimmedUsername.toLowerCase() };
    setUser(updatedUser);
    localStorage.setItem('gohar_user', JSON.stringify(updatedUser));
    return { ok: true };
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, changeCredentials, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
