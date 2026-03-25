import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import DashboardLayout from '@/components/layouts/DashboardLayout';
import { adminSidebarItems } from '@/config/adminSidebar';
import { Loader2 } from 'lucide-react';
import HolidayCalendarContent from '@/components/holiday-calendar/HolidayCalendarContent';

export default function HolidayCalendar() {
    const { user, userRole, loading } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        if (!loading && (!user || userRole !== 'admin')) navigate('/auth');
    }, [user, userRole, loading, navigate]);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <DashboardLayout sidebarItems={adminSidebarItems} roleColor="admin">
            <HolidayCalendarContent />
        </DashboardLayout>
    );
}
