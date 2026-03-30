const DARK_MODE_KEY = 'qr_attendance_dark_mode';


export function getDarkMode(): boolean {
	if ( typeof localStorage === 'undefined' ) return false;

    const saved = localStorage.getItem( DARK_MODE_KEY );

    if ( saved !== null ) return saved === 'true';

    return window.matchMedia( '(prefers-color-scheme: dark)' ).matches;
}


export function setDarkMode( enabled: boolean ): void {
	localStorage.setItem( DARK_MODE_KEY, String( enabled ) );

    if ( enabled ) {
		document.documentElement.classList.add( 'dark' );
	} else {
		document.documentElement.classList.remove( 'dark' );
	}
}


export function initDarkMode(): boolean {
	const isDark = getDarkMode();
	setDarkMode( isDark );
	return isDark;
}
