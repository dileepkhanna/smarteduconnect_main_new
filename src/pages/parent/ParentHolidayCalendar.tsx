import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import DashboardLayout from '@/components/layouts/DashboardLayout';
import { parentSidebarItems } from '@/config/parentSidebar';
import { Loader2 } from 'lucide-react';
import HolidayCalendarContent from '@/components/holiday-calendar/HolidayCalendarContent';

export default function ParentHolidayCalendar() {
    const { user, userRole, loading } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        if (!loading && (!user || userRole !== 'parent')) navigate('/auth');
    }, [user, userRole, loading, navigate]);

    if (loading) {
        return (
            <DashboardLayout sidebarItems={parentSidebarItems} roleColor="parent">
                <div className="flex items-center justify-center py-20">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout sidebarItems={parentSidebarItems} roleColor="parent">
            <HolidayCalendarContent />
        </DashboardLayout>
    );
}
