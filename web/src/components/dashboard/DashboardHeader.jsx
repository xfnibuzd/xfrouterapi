/*
Copyright (C) 2025 QuantumNous

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For commercial licensing, please contact support@quantumnous.com
*/

import React from 'react';
import { Button } from '@douyinfe/semi-ui';
import { RefreshCw, Search } from 'lucide-react';

const DashboardHeader = ({
  getGreeting,
  greetingVisible,
  showSearchModal,
  refresh,
  loading,
}) => {
  return (
    <div className='flex flex-col lg:flex-row lg:items-end lg:justify-between gap-3 mb-5'>
      <h2
        className='text-2xl lg:text-[30px] font-semibold tracking-tight text-[var(--docs-text)] transition-opacity duration-1000 ease-in-out'
        style={{ opacity: greetingVisible ? 1 : 0 }}
      >
        {getGreeting}
      </h2>
      <div className='flex items-center gap-2'>
        <Button
          type='tertiary'
          icon={<Search size={16} />}
          onClick={showSearchModal}
          className='docs-icon-button !text-white !rounded-full !bg-[var(--docs-primary)] hover:!bg-[var(--docs-primary-strong)]'
        />
        <Button
          type='tertiary'
          icon={<RefreshCw size={16} />}
          onClick={refresh}
          loading={loading}
          className='docs-icon-button !text-white !rounded-full !bg-[var(--docs-primary)] hover:!bg-[var(--docs-primary-strong)]'
        />
      </div>
    </div>
  );
};

export default DashboardHeader;
