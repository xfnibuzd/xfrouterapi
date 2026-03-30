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
import { Button, Dropdown } from '@douyinfe/semi-ui';
import { Languages } from 'lucide-react';

const LanguageSelector = ({ currentLang, onLanguageChange, t }) => {
  return (
    <Dropdown
      position='bottomRight'
      render={
        <Dropdown.Menu className='!bg-white !border !border-[var(--docs-border)] !shadow-lg !rounded-lg'>
          {/* Language sorting: Order by English name (Chinese, English, French, Japanese, Russian) */}
          <Dropdown.Item
            onClick={() => onLanguageChange('zh-CN')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'zh-CN' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            简体中文
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('zh-TW')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'zh-TW' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            繁體中文
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('en')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'en' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            English
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('fr')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'fr' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            Français
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('ja')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'ja' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            日本語
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('ru')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'ru' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            Русский
          </Dropdown.Item>
          <Dropdown.Item
            onClick={() => onLanguageChange('vi')}
            className={`!px-3 !py-1.5 !text-sm !text-semi-color-text-0 ${currentLang === 'vi' ? '!bg-[var(--docs-primary-soft)] !font-semibold' : 'hover:!bg-[var(--docs-primary-soft)]'}`}
          >
            Tiếng Việt
          </Dropdown.Item>
        </Dropdown.Menu>
      }
    >
      <Button
        icon={<Languages size={18} />}
        aria-label={t('common.changeLanguage')}
        theme='borderless'
        type='tertiary'
        className='docs-icon-button !p-1.5 !text-current !rounded-full'
      />
    </Dropdown>
  );
};

export default LanguageSelector;
