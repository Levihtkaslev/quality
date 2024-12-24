import React from 'react';
import { Link } from 'react-router-dom';

function Menu() {
    return (
        <nav className="bg-blue-800 shadow-md shadow-blue-400 rounded-b-2xl">
            <div className="w-full  px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-24">
                    
                    <h3 className="text-3xl text-white">Quality Issue Tracker</h3>

                   
                    <ul className="flex  gap-6 items-end">
                        <li>
                            <Link to="/" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 50 50"
                                    width="20px"
                                    height="25px"
                                >
                                    <path d="M 41.707031 ... Z" />
                                </svg>
                                <span className="ml-2">Ticket Form</span>
                            </Link>
                        </li>
                        <li>
                            <Link to="/location" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    fill="currentColor"
                                    width="24px"
                                    height="25px"
                                >
                                    <path d="M12 2C ... 11.5Z" />
                                </svg>
                                <span className="ml-2">Locations</span>
                            </Link>
                        </li>
                        <li>
                            <Link to="/department" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    fill="currentColor"
                                    width="20px"
                                    height="24px"
                                >
                                    <path d="M3 2C ... 6Z" />
                                </svg>
                                <span className="ml-2">Departments</span>
                            </Link>
                        </li>
                        <li>
                            <Link to="/report" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="23"
                                    height="25"
                                    viewBox="0 0 50 50"
                                >
                                    <path d="M38 ... Z" />
                                </svg>
                                <span className="ml-2">Report Info</span>
                            </Link>
                        </li>
                        <li>
                            <Link to="/media" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    width="23"
                                    height="27"
                                >
                                    <path d="M12 ... Z" />
                                </svg>
                                <span className="ml-2">Media</span>
                            </Link>
                        </li>
                        <li>
                            <Link to="" className="text-white hover:text-gray-200 flex items-center">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    width="23"
                                    height="25"
                                >
                                    <path d="M13 ... Z" />
                                </svg>
                                <span className="ml-2">Log Out</span>
                            </Link>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    );
}

export default Menu;
