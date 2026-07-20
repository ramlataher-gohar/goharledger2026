import { createContext, useContext, useState, useCallback, useEffect, type ReactNode } from 'react';
import { supabase } from '../utils/supabase';

interface DataContextType {
  refreshKey: number;
  triggerRefresh: () => void;
}

const DataContext = createContext<DataContextType>({ refreshKey: 0, triggerRefresh: () => {} });

export function DataProvider({ children }: { children: ReactNode }) {
  const [refreshKey, setRefreshKey] = useState(0);

  const triggerRefresh = useCallback(() => {
    setRefreshKey((k) => k + 1);
  }, []);

  // A tab left idle in the background can have its auth token refresh timer
  // frozen by the browser, and every page's data just goes stale until a
  // manual reload. Resuming the token refresh and re-fetching data as soon
  // as the tab is visible again avoids needing that manual reload.
  useEffect(() => {
    function handleVisibilityChange() {
      if (document.visibilityState === 'visible') {
        supabase.auth.startAutoRefresh();
        triggerRefresh();
      } else {
        supabase.auth.stopAutoRefresh();
      }
    }
    document.addEventListener('visibilitychange', handleVisibilityChange);
    return () => document.removeEventListener('visibilitychange', handleVisibilityChange);
  }, [triggerRefresh]);

  return (
    <DataContext.Provider value={{ refreshKey, triggerRefresh }}>
      {children}
    </DataContext.Provider>
  );
}

export function useDataRefresh() {
  return useContext(DataContext);
}
