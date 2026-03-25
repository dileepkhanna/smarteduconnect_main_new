import { useEffect, useState } from 'react';
import { Plus } from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Loader2 } from 'lucide-react';

import { fetchHolidays, deleteHoliday } from './holidayApi';
import type { Holiday } from './types';
import CalendarView from './CalendarView';
import ListView from './ListView';
import Legend from './Legend';
import AddEditHolidayModal from './AddEditHolidayModal';

export default function HolidayCalendarContent() {
    const { userRole } = useAuth();
    const isAdmin = userRole === 'admin';

    const now = new Date();
    const [currentYear, setCurrentYear] = useState(now.getFullYear());
    const [currentMonth, setCurrentMonth] = useState(now.getMonth());
    const [holidays, setHolidays] = useState<Holiday[]>([]);
    const [loadingHolidays, setLoadingHolidays] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [modalState, setModalState] = useState<{ open: boolean; holiday: Holiday | null }>({
        open: false,
        holiday: null,
    });

    const loadHolidays = async (year: number) => {
        setLoadingHolidays(true);
        try {
            const data = await fetchHolidays(year);
            setHolidays(data ?? []);
        } catch {
            setHolidays([]);
        } finally {
            setLoadingHolidays(false);
        }
    };

    useEffect(() => {
        loadHolidays(currentYear);
    }, [currentYear]);

    const handlePrevMonth = () => {
        if (currentMonth === 0) {
            setCurrentMonth(11);
            setCurrentYear((y) => y - 1);
        } else {
            setCurrentMonth((m) => m - 1);
        }
    };

    const handleNextMonth = () => {
        if (currentMonth === 11) {
            setCurrentMonth(0);
            setCurrentYear((y) => y + 1);
        } else {
            setCurrentMonth((m) => m + 1);
        }
    };

    const handleYearChange = (year: number) => {
        setCurrentYear(year);
    };

    const handleEdit = (holiday: Holiday) => {
        setModalState({ open: true, holiday });
    };

    const handleDelete = async (holiday: Holiday) => {
        if (!window.confirm(`Delete "${holiday.name}"? This action cannot be undone.`)) return;
        try {
            await deleteHoliday(holiday.id);
            await loadHolidays(currentYear);
        } catch {
            // error handled silently; toast could be added here
        }
    };

    const handleSaved = async (_saved: Holiday) => {
        setModalState({ open: false, holiday: null });
        await loadHolidays(currentYear);
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Page header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="font-display text-2xl font-bold">Holiday Calendar</h1>
                    <p className="text-muted-foreground text-sm">View and manage school holidays</p>
                </div>
                {isAdmin && (
                    <Button onClick={() => setModalState({ open: true, holiday: null })}>
                        <Plus className="h-4 w-4 mr-1" /> Add Holiday
                    </Button>
                )}
            </div>

            {loadingHolidays ? (
                <div className="flex items-center justify-center py-20">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
            ) : (
                <>
                    {/* Two-column layout: calendar left, list right */}
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
                        {/* Left: Calendar */}
                        <div className="space-y-4">
                            <CalendarView
                                holidays={holidays}
                                year={currentYear}
                                month={currentMonth}
                                onPrevMonth={handlePrevMonth}
                                onNextMonth={handleNextMonth}
                                onYearChange={handleYearChange}
                                isAdmin={isAdmin}
                                onEdit={handleEdit}
                                onDelete={handleDelete}
                            />
                            <Legend />
                        </div>

                        {/* Right: Search + List */}
                        <div className="space-y-3">
                            <Input
                                placeholder="Search holidays…"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                            <ListView
                                holidays={holidays}
                                searchQuery={searchQuery}
                                isAdmin={isAdmin}
                                onEdit={handleEdit}
                                onDelete={handleDelete}
                            />
                        </div>
                    </div>
                </>
            )}

            <AddEditHolidayModal
                open={modalState.open}
                holiday={modalState.holiday}
                onClose={() => setModalState({ open: false, holiday: null })}
                onSaved={handleSaved}
            />
        </div>
    );
}
